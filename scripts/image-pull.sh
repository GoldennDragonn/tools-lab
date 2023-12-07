#!/bin/bash

usage() {
    echo "Usage: $0 <file_path>"
    exit 1
}

if [ "$#" -ne 1 ]; then
    usage
fi

file_path=$1

if [ ! -f "$file_path" ]; then
    echo "File not found: $file_path"
    usage
fi

while IFS= read -r line; do
    echo "Pulling image: $line"
    docker pull "$line"
done < "$file_path"

echo "Finished pulling all images."
