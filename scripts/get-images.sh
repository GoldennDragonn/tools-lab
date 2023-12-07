#!/bin/bash

USERNAME=""
PASSWORD=""
REPO_URL=""

OUTPUT_FILE="images.txt"

usage() {
    echo "Usage: $0 -u <username> -p <password> -r <repo_url>"
    exit 1
}

while getopts "u:p:r:" opt; do
    case $opt in
        u) USERNAME="$OPTARG" ;;
        p) PASSWORD="$OPTARG" ;;
        r) REPO_URL="$OPTARG" ;;
        *) usage ;;
    esac
done

if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ] || [ -z "$REPO_URL" ]; then
    usage
fi
OUTPUT_FILE="images.txt"

url_prefix=$REPO_URL

IMAGES=$(curl -u $USERNAME:$PASSWORD -k -s -X GET "https://$REPO_URL/v2/_catalog" | jq -r '.repositories[]')

echo "Fetching image tags..."
for image in $IMAGES; do
    TAGS=$(curl -u $USERNAME:$PASSWORD -k -s -X GET "https://$REPO_URL/v2/$image/tags/list" | jq -r '.tags[]')
    for tag in $TAGS; do
        echo "$url_prefix/$image:$tag" >> $OUTPUT_FILE
    done
done

echo "List of images and tags saved to $OUTPUT_FILE"
