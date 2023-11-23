#!/bin/bash

# List of images
images=(
"nvcr.io/nvidia/cloud-native/gpu-operator-validator:v23.6.1"
"nvcr.io/nvidia/gpu-operator:v23.6.1"
"nvcr.io/nvidia/cuda:12.2.0-base-ubi8"
"nvcr.io/nvidia/driver:535.104.05-ubuntu22.04"
"nvcr.io/nvidia/cloud-native/k8s-driver-manager:v0.6.2"
"nvcr.io/nvidia/k8s/container-toolkit:v1.13.4-ubuntu20.04"
"nvcr.io/nvidia/k8s-device-plugin:v0.14.1-ubi8"
"nvcr.io/nvidia/cloud-native/dcgm:3.1.8-1-ubuntu20.04"
"nvcr.io/nvidia/k8s/dcgm-exporter:3.1.8-3.1.5-ubuntu20.04"
"nvcr.io/nvidia/gpu-feature-discovery:v0.8.1-ubi8"
"nvcr.io/nvidia/cloud-native/k8s-mig-manager:v0.5.3-ubuntu20.04"
"nvcr.io/nvidia/cloud-native/gpu-operator-validator:latest"
"nvcr.io/nvidia/cloud-native/nvidia-fs:2.16.1-ubuntu22.04"
"nvcr.io/nvidia/cloud-native/k8s-driver-manager:v0.6.2"
"nvcr.io/nvidia/cloud-native/vgpu-device-manager:v0.2.3"
"nvcr.io/nvidia/cuda:12.2.0-base-ubi8"
"nvcr.io/nvidia/cloud-native/k8s-driver-manager:v0.6.2"
"nvcr.io/nvidia/cloud-native/k8s-kata-manager:v0.1.1"
"nvcr.io/nvidia/kubevirt-gpu-device-plugin:v1.2.2"
"nvcr.io/nvidia/cloud-native/k8s-cc-manager:v0.1.0"
)

# Loop through images and pull & save them
for image in "${images[@]}"; do
    echo "Pulling $image..."
    docker pull $image
    echo "Saving $image as tarball..."
    image_name=$(echo $image | tr "/" "_" | tr ":" "-")
    docker save $image -o "${image_name}.tar"
done

echo "All images pulled and saved."

