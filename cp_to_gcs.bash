#!/bin/bash

# Configuration
# PROJECT_ID="socket-research-wenxin"
# BUCKET_NAME="socket-hf-data"
PROJECT_ID="socket-metadata-staging"
BUCKET_NAME="socket-typosquat-lfs"
SOURCE_DIR="$(dirname "$(realpath "$0")")"  # Parent directory of the script

# Check if gsutil is installed
if ! command -v gsutil &> /dev/null; then
    echo "Error: gsutil is not installed. Please install Google Cloud SDK first."
    exit 1
fi

# Ensure we're authenticated
if ! gsutil ls gs://${BUCKET_NAME} &> /dev/null; then
    echo "Error: Cannot access bucket. Please check authentication and bucket name."
    exit 1
fi

# Copy the repository to GCS
echo "Copying repository from ${SOURCE_DIR} to gs://${BUCKET_NAME}..."
gsutil -m cp -r "${SOURCE_DIR}" "gs://${BUCKET_NAME}/"

if [ $? -eq 0 ]; then
    echo "Successfully copied repository to GCS bucket"
else
    echo "Error occurred while copying repository"
    exit 1
fi