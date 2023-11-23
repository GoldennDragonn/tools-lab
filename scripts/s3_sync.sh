#!/bin/bash


LOCAL_DIR="/home/yakovbe/Downloads/AWSTEST"

# Set the S3 bucket and path where you want to upload
S3_BUCKET="s3://yakovbetest/Downloads/"

aws s3 sync "$LOCAL_DIR" "$S3_BUCKET" --exclude "*" --include "*" 