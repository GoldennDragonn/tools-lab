#!/bin/bash

# Get all the docker images
images=($(docker images --format "{{.Repository}}:{{.Tag}}"))

# Check if no images found
if [[ ${#images[@]} -eq 0 ]]; then
    echo "No Docker images found."
    exit 1
fi

# Prompt for the new repository prefix
read -p "Enter the new repository prefix (e.g. yakovb:4000): " new_repo

# Display images and prompt user for selections
echo "Loaded Docker images:"
for i in "${!images[@]}"; do
    echo "$((i+1)). ${images[$i]}"
done

echo -e "\nSelect images by:"
echo "1. Entering numbers or a range of the images (e.g. 1 3 5 or 2-4)"
echo "2. Using a keyword to select matching images (e.g. ubuntu)"
echo "3. Typing 'all' to select all"
echo "4. Exit"
read -a selections

# Exit option
if [[ ${selections[0]} == "4" ]]; then
    echo "Exiting..."
    exit 0
fi

# Determine the type of selection: numbers, keyword, or all
if [[ ${selections[0]} == "all" ]]; then
    selected_images=("${images[@]}")
elif [[ ${selections[0]} =~ ^[0-9]+$ || ${selections[0]} =~ ^[0-9]+-[0-9]+$ ]]; then
    for selection in "${selections[@]}"; do
        if [[ $selection =~ ^[0-9]+$ ]]; then
            index=$((selection-1))
            selected_images+=("${images[$index]}")
        elif [[ $selection =~ ^[0-9]+-[0-9]+$ ]]; then
            IFS='-' read -ra range <<< "$selection"
            start=$((range[0]-1))
            end=$((range[1]-1))
            for ((i=$start; i<=$end; i++)); do
                selected_images+=("${images[$i]}")
            done
        fi
    done
else
    keyword="${selections[0]}"
    for image in "${images[@]}"; do
        if [[ $image == *$keyword* ]]; then
            selected_images+=("$image")
        fi
    done
fi

# Loop through selected images and tag them
for image in "${selected_images[@]}"; do
    new_image="$new_repo/$image"
    docker tag "$image" "$new_image" && echo "Tagged $image as $new_image"
done

# Ask user if they want to push the retagged images
read -p "Push all retagged images to new repo? (yes/no): " push_decision
if [[ $push_decision == "yes" ]]; then
    for new_image in "${selected_images[@]}"; do
        docker push "$new_repo/$new_image" && echo "Pushed $new_repo/$new_image successfully" || echo "Failed to push $new_repo/$new_image"
    done
else
    echo "Images not pushed."
fi
