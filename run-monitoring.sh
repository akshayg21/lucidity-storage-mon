#!/bin/bash

# Multi-Account EC2 Disk Monitoring Script
set -e

echo "=== AWS Multi-Account Disk Monitoring ==="

# Install required collections
echo "Installing Ansible collections..."
ansible-galaxy collection install -r requirements.yml

# Setup cross-account roles (run once)
if [ "$1" = "--setup-roles" ]; then
    echo "Setting up cross-account IAM roles..."
    ansible-playbook setup-cross-account-roles.yml
    exit 0
fi

# Run EBS volume monitoring across all accounts
echo "Starting EBS volume monitoring via AWS APIs..."
ansible-playbook disk-monitoring.yml -v

echo "Volume monitoring complete. Reports generated in ./reports/"
echo "Check S3 bucket 'enterprise-disk-monitoring-reports' for uploaded reports."