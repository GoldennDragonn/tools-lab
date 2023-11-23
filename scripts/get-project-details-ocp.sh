#!/bin/bash

CURRENT_DATE=$(date +"%Y-%m-%d %H:%M:%S")

read -p "Enter the project names (comma-separated without spaces): " INPUT_PROJECTS
IFS=',' read -ra PROJECTS <<< "$INPUT_PROJECTS"

RESOURCES=("pods" "services" "routes" "configmaps" "secrets" "deployments" "persistentvolumeclaims" "statefulsets" "daemonsets")

for PROJECT in "${PROJECTS[@]}"
do
    OUTPUT_FILE="ocp-$PROJECT-report.csv"
    
    {
        # Fetching OCP Client, Server, and K8s versions
        OCP_CLIENT_VERSION=$(oc version | grep "Client Version:" | awk -F'[: ]+' '{print $3}')
        OCP_SERVER_VERSION=$(oc version | grep "Server Version:" | awk -F'[: ]+' '{print $3}')
        K8S_VERSION=$(oc version | grep "Kubernetes Version:" | awk -F'[: ]+' '{print $3}')
        
        echo "OpenShift Client Version: $OCP_CLIENT_VERSION"
        echo "OpenShift Server Version: $OCP_SERVER_VERSION"
        echo "Kubernetes Version: $K8S_VERSION"
        echo "----------------------------------"

        echo "Details for project: $PROJECT"
        echo "----------------------------------"
        
        oc project $PROJECT > /dev/null 2>&1

        for RESOURCE in "${RESOURCES[@]}"
        do
            echo "Resource type: $RESOURCE"

            if [ "$RESOURCE" == "services" ]; then
                echo "Service Name,Port"
                oc get services -o=jsonpath="{range .items[*]}{.metadata.name},{.spec.ports[0].port}{'\n'}{end}"
            elif [ "$RESOURCE" == "routes" ]; then
                echo "Route Name,URL"
                oc get routes -o=jsonpath="{range .items[*]}{.metadata.name},{.spec.host}{'\n'}{end}"
            elif [ "$RESOURCE" == "persistentvolumeclaims" ]; then
                echo "PVC Name,Capacity"
                oc get pvc -o=jsonpath="{range .items[*]}{.metadata.name},{.spec.resources.requests.storage}{'\n'}{end}"
            elif [ "$RESOURCE" == "pods" ]; then
                echo "Pod Name,Status,Execution Date"
                oc get pods -o custom-columns=NAME:.metadata.name,PHASE:.status.phase,WAITING:.status.containerStatuses[0].state.waiting.reason,TERMINATED:.status.containerStatuses[0].state.terminated.reason | \
                    awk -v date="$CURRENT_DATE" 'BEGIN {OFS=","} {if (NR!=1) {status=$2; if ($3 != "" && $3 != "<none>") status=$3; else if ($4 != "" && $4 != "<none>") status=$4; print $1,status,date}}'
            elif [ "$RESOURCE" == "secrets" ]; then
                echo "Secret Name,Type"
                oc get secrets -o=jsonpath="{range .items[*]}{.metadata.name},{.type}{'\n'}{end}"
            elif [ "$RESOURCE" == "deployments" ]; then
                echo "Deployment Name"
                oc get deployments -o=jsonpath="{range .items[*]}{.metadata.name}{'\n'}{end}"
            elif [ "$RESOURCE" == "statefulsets" ]; then
                echo "StatefulSet Name,Desired Replicas,Current Replicas"
                oc get statefulsets -o=jsonpath="{range .items[*]}{.metadata.name},{.spec.replicas},{.status.replicas}{'\n'}{end}"
            elif [ "$RESOURCE" == "daemonsets" ]; then
                echo "DaemonSet Name,Current Replicas"
                oc get daemonsets -o=jsonpath="{range .items[*]}{.metadata.name},{.status.currentNumberScheduled}{'\n'}{end}"
            else
                echo "Resource Name"
                oc get $RESOURCE -o=jsonpath="{range .items[*]}{.metadata.name}{'\n'}{end}"
            fi
            echo ""
        done

        echo "Operators"
        echo "Operator Name,Version"
        OPERATORS=$(oc get csv -o=jsonpath="{range .items[*]}{.metadata.name},{.spec.version}{'\n'}{end}")
        if [ -z "$OPERATORS" ]; then
            echo "No operators installed in this project."
        else
            echo "$OPERATORS"
        fi

        echo "----------------------------------"
    } > "$OUTPUT_FILE"

    echo "Report saved to $OUTPUT_FILE"
done
