#!/usr/bin/env bash
# Use Bash to run this script, no matter where Bash is installed.
# This is more portable than hardcoding something like /bin/bash.

# Safety settings:
# -e  = exit immediately if any command returns a non-zero status
# -u  = treat unset variables as an error and exit
# -o pipefail = if a pipeline fails anywhere, treat the whole pipeline as failed
#
# Together, these make the script safer and easier to debug.
set -euo pipefail

# Determine the directory where this script itself is located.
#
# Breakdown:
# - BASH_SOURCE[0] = path of the current script
# - dirname ...    = directory containing the script
# - cd ... && pwd  = move there and print the absolute path
#
# This is useful because it makes the script work regardless of
# where you run it from.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Go one level up from the script directory to find the repository root.
#
# Example:
# If SCRIPT_DIR is:
#   /home/user/project/scripts
# then REPO_ROOT becomes:
#   /home/user/project
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

validate_structure() {
    # Build the path to the Terraform directory.
    TF_DIR="$REPO_ROOT/terraform"

    # Build the path to the Terraform environment directory based on ENVIRONMENT.
    TF_PLA_DIR="$TF_DIR/platform"

    # Build the path to the Terraform platform access directory.
    TF_PLA_ACC_DIR="$TF_DIR/platform-access/github-actions"

    # Check whether the Terraform directory exists.
    # If it does not exist, print an error and stop the script.
    #
    # -d checks whether the path exists and is a directory.
    if [[ ! -d "$TF_PLA_DIR" ]]; then
    echo "Error: Terraform environment directory not found: $TF_PLA_DIR"
    exit 1
    fi

    # Check whether the Terraform directory exists.
    # If it does not exist, print an error and stop the script.
    #
    # -d checks whether the path exists and is a directory.
    if [[ ! -d "$TF_PLA_ACC_DIR" ]]; then
    echo "Error: Terraform environment directory not found: $TF_PLA_ACC_DIR"
    exit 1
    fi
}

setup_config() {
    # Setup EKS cluster connection
    aws eks update-kubeconfig \
    --region eu-west-1 \
    --name "platform-engineering-aws-eks"
}

setup_profile() {
    export AWS_PROFILE=aws-administrator
}