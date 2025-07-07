# Multi-Account AWS EC2 Disk Utilization Monitoring

## Solution Overview

This Ansible-based solution monitors disk utilization across EC2 instances in multiple AWS accounts, providing centralized reporting and alerting capabilities.

## Architecture Components

### 1. Centralized Access Management
- **Cross-Account IAM Roles**: Each target account has a `DiskMonitoringRole` that can be assumed by the central management account
- **Dynamic Inventory**: AWS EC2 plugin automatically discovers instances across all configured accounts and regions
- **API-Only Access**: Uses AWS EBS APIs to collect volume information without connecting to instances

### 2. Data Aggregation
- **EBS Volume Data**: Direct AWS API calls to get volume size, type, and attachment information
- **JSON Reports**: Structured data for programmatic processing
- **CSV Reports**: Human-readable format for spreadsheet analysis  
- **S3 Storage**: Centralized report storage with versioning
- **Real-time Summary**: Console output with key metrics and alerts

### 3. Scalability Features
- **Account Configuration**: Simple YAML configuration for adding new accounts
- **Region Support**: Multi-region monitoring with configurable region list
- **Platform Agnostic**: Supports both Linux and Windows instances
- **Caching**: Inventory caching reduces API calls and improves performance

## Quick Start

### Prerequisites
```bash
pip install ansible boto3 botocore
```

### Setup
1. **Install collections**:
   ```bash
   ansible-galaxy collection install -r requirements.yml
   ```

2. **Configure AWS credentials** for central account with cross-account assume role permissions

3. **Setup cross-account roles** (one-time):
   ```bash
   ./run-monitoring.sh --setup-roles
   ```

4. **Run monitoring**:
   ```bash
   ./run-monitoring.sh
   ```

## Configuration

### Adding New Accounts
Edit `inventory/aws_ec2.yml`:
```yaml
compose:
  account_name: |
    {
      '111111111111': 'production',
      '222222222222': 'staging', 
      '333333333333': 'development',
      '444444444444': 'new-acquisition'  # Add here
    }[account_id]
```

### Adding New Regions
Edit `inventory/aws_ec2.yml`:
```yaml
regions:
  - us-east-1
  - us-west-2
  - eu-west-1
  - ap-southeast-1  # Add here
```

## Output Formats

### JSON Report Structure
```json
{
  "instance_id": "i-1234567890abcdef0",
  "account_id": "111111111111",
  "account_name": "production",
  "region": "us-east-1",
  "disk_usage": [
    {
      "filesystem": "/dev/xvda1",
      "size": "8.0G",
      "used": "2.1G", 
      "available": "5.6G",
      "percent": 28,
      "mount": "/"
    }
  ]
}
```

### CSV Report Columns
- Instance ID, Account ID, Account Name, Region
- Instance Type, Platform, Private IP, Public IP  
- Filesystem, Size, Used, Available, Percent Used
- Mount Point, Timestamp

## Security Considerations

- **Least Privilege**: IAM roles have minimal required permissions
- **External ID**: Additional security layer for role assumption
- **Temporary Credentials**: STS tokens expire automatically
- **Audit Trail**: All actions logged via CloudTrail

## Monitoring and Alerting

The solution provides:
- **High Usage Detection**: Automatically identifies disks >80% full
- **Account Coverage**: Reports total instances monitored per account
- **Failure Handling**: Continues processing if individual instances fail
- **Historical Data**: S3 storage enables trend analysis

## Scaling for Future Growth

### Adding New Accounts (Acquisitions)
1. Update account mapping in inventory configuration
2. Deploy IAM role to new account using setup playbook
3. No changes needed to main monitoring playbook

### Performance Optimization
- **Parallel Execution**: Ansible runs tasks across instances simultaneously
- **Inventory Caching**: Reduces AWS API calls
- **Regional Batching**: Can be configured to process regions separately
- **Selective Monitoring**: Filter by tags, instance types, or other criteria

### Integration Options
- **CI/CD Integration**: Run as scheduled job in Jenkins/GitLab
- **Monitoring Tools**: Export to Prometheus, Grafana, or CloudWatch
- **Alerting**: Integrate with PagerDuty, Slack, or email notifications
- **Automation**: Trigger auto-scaling or cleanup based on thresholds

### Assumption
- **Networking**: Networking setup is done independent of this solution
- **Account integration**: VPC peering or transit gateway setup is already completed.