#!/bin/bash

# Configuration
# PROJECT_ID="socket-research-wenxin"
# BUCKET_NAME="socket-hf-data"
BUCKET_NAME_STAGING="socketsecurity-typosquat-models-staging"  # Staging bucket
BUCKET_NAME_PROD="socketsecurity-typosquat-models-prod"   # Production bucket
SOURCE_DIR="$(dirname "$(realpath "$0")")"  # Parent directory of the script

# Check if gsutil is installed
if ! command -v gsutil &> /dev/null; then
    echo "Error: gsutil is not installed. Please install Google Cloud SDK first."
    exit 1
fi

# Ensure we're authenticated for both buckets
if ! gsutil ls gs://${BUCKET_NAME_STAGING} &> /dev/null; then
    echo "Error: Cannot access staging bucket. Please check authentication and bucket name."
    exit 1
fi

if ! gsutil ls gs://${BUCKET_NAME_PROD} &> /dev/null; then
    echo "Error: Cannot access production bucket. Please check authentication and bucket name."
    exit 1
fi

# Remove existing .git folders from buckets and copy repository excluding .git
echo "Cleaning up existing .git folder from staging bucket..."
gsutil -m rm -r "gs://${BUCKET_NAME_STAGING}/typosquat-lfs/.git" &> /dev/null || true

echo "Cleaning up existing .git folder from production bucket..."
gsutil -m rm -r "gs://${BUCKET_NAME_PROD}/typosquat-lfs/.git" &> /dev/null || true

echo "Copying repository (excluding .git) from ${SOURCE_DIR} to staging bucket gs://${BUCKET_NAME_STAGING}..."
gsutil -m cp -r "${SOURCE_DIR}" "gs://${BUCKET_NAME_STAGING}/" -x "\.git(\/.*)?$"

if [ $? -eq 0 ]; then
    echo "Successfully copied repository to staging bucket"
else
    echo "Error occurred while copying repository to staging bucket"
    exit 1
fi

echo "Copying repository (excluding .git) from ${SOURCE_DIR} to production bucket gs://${BUCKET_NAME_PROD}..."
gsutil -m cp -r "${SOURCE_DIR}" "gs://${BUCKET_NAME_PROD}/" -x "\.git(\/.*)?$"

if [ $? -eq 0 ]; then
    echo "Successfully copied repository to production bucket"
else
    echo "Error occurred while copying repository to production bucket"
    exit 1
fi