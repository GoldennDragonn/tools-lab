#!/bin/bash

SECRETS_ERROR_PRINTED=0
# Capture the current date
CURRENT_DATE=$(date +"%Y-%m-%d %H:%M:%S")

# Prompt user for context names (comma-separated)
read -p "Enter the context names (comma-separated without spaces): " INPUT_CONTEXTS
IFS=',' read -ra CONTEXTS <<< "$INPUT_CONTEXTS"

# Array of resource types we're interested in
RESOURCES=("pods" "services" "deployments" "configmaps" "secrets" "persistentvolumeclaims" "ingresses.networking.k8s.io" "statefulsets" "daemonsets")

# Namespaces to ignore
IGNORED_NAMESPACES=("kube-node-lease" "kube-public" "kube-system")

for CONTEXT in "${CONTEXTS[@]}"
do
    OUTPUT_FILE="eks-$CONTEXT-report.csv"
    echo "Details for context: $CONTEXT" > $OUTPUT_FILE
    echo "----------------------------------" >> $OUTPUT_FILE
    
    # Switch to the context
    kubectl config use-context $CONTEXT

    # List all namespaces in the current context and display them to the user
    NAMESPACES_LIST=$(kubectl get namespaces -o=jsonpath='{.items[*].metadata.name}')
    echo "Available namespaces in context $CONTEXT: $NAMESPACES_LIST"

    # Ask user to select specific namespaces or all
    read -p "Enter the namespace names (comma-separated without spaces) or 'all' to choose all: " USER_NAMESPACES

    if [ "$USER_NAMESPACES" != "all" ]; then
        IFS=',' read -ra NAMESPACES <<< "$USER_NAMESPACES"
    else
        IFS=' ' read -ra NAMESPACES <<< "$NAMESPACES_LIST"
    fi

    # Display Kubernetes version
    echo "Kubernetes Version," >> $OUTPUT_FILE
    kubectl version | grep "Server Version:" | awk '{print $3}' >> $OUTPUT_FILE
    echo "----------------------------------" >> $OUTPUT_FILE

    # Check if helm is installed and if so, display chart versions
    if command -v helm &> /dev/null; then
        echo "Helm Chart Names,Namespace,Revision,Updated,Status,Chart,App Version" >> $OUTPUT_FILE
        helm list -A | tail -n +2 | awk 'BEGIN {OFS=","} {print $1,$2,$3,$4 " " $5 " " $6 " " $7,$8,$9,$10}' >> $OUTPUT_FILE
        echo "----------------------------------" >> $OUTPUT_FILE
    else
        echo "Helm is not installed or not in PATH," >> $OUTPUT_FILE
        echo "----------------------------------" >> $OUTPUT_FILE
    fi

    for NAMESPACE in "${NAMESPACES[@]}"
    do
        if [[ " ${IGNORED_NAMESPACES[@]} " =~ " ${NAMESPACE} " ]]; then
            # Skip the namespace if it's in the ignored list
            continue
        fi

        SECRETS_ERROR_PRINTED=0
        CLUSTER_SCOPE_ERROR_PRINTED=0

        echo "Namespace: $NAMESPACE" >> $OUTPUT_FILE
        echo "----------------------------------" >> $OUTPUT_FILE
        
        # Gather details of various resources in the current namespace
        for RESOURCE in "${RESOURCES[@]}"
        do
            if [ "$RESOURCE" == "services" ]; then
                SVC_OUTPUT=$(kubectl get services -n $NAMESPACE -o custom-columns=NAME:.metadata.name,PORT:.spec.ports[0].port --no-headers)
                if [[ ! -z "$SVC_OUTPUT" ]]; then
                    echo "Service Name,Port" >> $OUTPUT_FILE
                    echo "$SVC_OUTPUT" | awk 'BEGIN {OFS=","} {print $1,$2}' >> $OUTPUT_FILE
                fi
            elif [ "$RESOURCE" == "deployments" ]; then
                DEPLOY_OUTPUT=$(kubectl get deployments -n $NAMESPACE -o custom-columns=NAME:.metadata.name --no-headers)
                if [[ ! -z "$DEPLOY_OUTPUT" ]]; then
                    echo "Deployment Name" >> $OUTPUT_FILE
                    echo "$DEPLOY_OUTPUT" >> $OUTPUT_FILE
                fi
            elif [ "$RESOURCE" == "secrets" ]; then
                SECRET_OUTPUT=$(kubectl get secrets -n $NAMESPACE -o custom-columns=NAME:.metadata.name,TYPE:.type --no-headers 2>&1)
                if [[ $? -ne 0 ]]; then
                    if [[ "$SECRET_OUTPUT" == *"at the cluster scope"* && $CLUSTER_SCOPE_ERROR_PRINTED -eq 0 ]]; then
                        echo "Permission to fetch secrets at the cluster scope is denied." >&2
                        CLUSTER_SCOPE_ERROR_PRINTED=1
                    elif [[ "$SECRET_OUTPUT" == *"in the namespace"* && $SECRETS_ERROR_PRINTED -eq 0 ]]; then
                        echo "Permission to fetch secrets is denied for namespace $NAMESPACE." >&2
                        SECRETS_ERROR_PRINTED=1
                    fi
                    continue
                fi
                if [[ ! -z "$SECRET_OUTPUT" ]]; then
                    echo "Secret Name,Type" >> $OUTPUT_FILE
                    echo "$SECRET_OUTPUT" | awk 'BEGIN {OFS=","} {print $1,$2}' >> $OUTPUT_FILE
                fi

            elif [ "$RESOURCE" == "ingresses.networking.k8s.io" ]; then
                INGRESS_OUTPUT=$(kubectl get ingresses.networking.k8s.io -n $NAMESPACE -o=jsonpath="{range .items[*]}{.metadata.name},{.spec.rules[0].host}{.spec.rules[0].http.paths[0].path}{'\n'}{end}" 2>/dev/null)
                if [[ ! -z "$INGRESS_OUTPUT" ]]; then
                    echo "Ingress Name,URL" >> $OUTPUT_FILE
                    echo "$INGRESS_OUTPUT" >> $OUTPUT_FILE
                fi
            elif [ "$RESOURCE" == "statefulsets" ]; then
                STS_OUTPUT=$(kubectl get statefulsets -n $NAMESPACE -o custom-columns=NAME:.metadata.name,REPLICAS:.spec.replicas,CURRENT:.status.currentReplicas --no-headers)
                if [[ ! -z "$STS_OUTPUT" ]]; then
                    echo "StatefulSet Name,Desired Replicas,Current Replicas" >> $OUTPUT_FILE
                    echo "$STS_OUTPUT" | awk 'BEGIN {OFS=","} {print $1,$2,$3}' >> $OUTPUT_FILE
                fi
            elif [ "$RESOURCE" == "daemonsets" ]; then
                DS_OUTPUT=$(kubectl get daemonsets -n $NAMESPACE -o custom-columns=NAME:.metadata.name,DESIRED:.spec.replicas,CURRENT:.status.currentNumberScheduled --no-headers)
                if [[ ! -z "$DS_OUTPUT" ]]; then
                    echo "DaemonSet Name,Desired Replicas,Current Replicas" >> $OUTPUT_FILE
                    echo "$DS_OUTPUT" | awk 'BEGIN {OFS=","} {print $1,$2,$3}' >> $OUTPUT_FILE
                fi
            else
                RESOURCE_OUTPUT=$(kubectl get $RESOURCE -n $NAMESPACE 2>/dev/null)
                if [[ "$RESOURCE_OUTPUT" == *'No resources found'* ]] || [[ "$RESOURCE_OUTPUT" == '' ]]; then
                    # Skip the resource if it's empty in the namespace
                    continue
                fi

                if [ "$RESOURCE" == "pods" ]; then
                    echo "Pod Name,Status,Execution Date" >> $OUTPUT_FILE
                    kubectl get pods -n $NAMESPACE -o custom-columns=NAME:.metadata.name,PHASE:.status.phase,WAITING:.status.containerStatuses[0].state.waiting.reason,TERMINATED:.status.containerStatuses[0].state.terminated.reason --no-headers | \
                        awk -v date="$CURRENT_DATE" 'BEGIN {OFS=","} {status=$2; if ($3 != "" && $3 != "<none>") status=$3; else if ($4 != "" && $4 != "<none>") status=$4; print $1,status,date}' >> $OUTPUT_FILE
                elif [ "$RESOURCE" == "persistentvolumeclaims" ]; then
                    echo "PVC Name,Capacity" >> $OUTPUT_FILE
                    kubectl get pvc -n $NAMESPACE -o=jsonpath="{range .items[*]}{.metadata.name},{.spec.resources.requests.storage}{'\n'}{end}" >> $OUTPUT_FILE
                elif [ "$RESOURCE" == "configmaps" ]; then
                    CONFIG_OUTPUT=$(kubectl get configmaps -n $NAMESPACE -o custom-columns=NAME:.metadata.name --no-headers)
                    if [[ ! -z "$CONFIG_OUTPUT" ]]; then
                        echo "ConfigMap Name" >> $OUTPUT_FILE
                        echo "$CONFIG_OUTPUT" >> $OUTPUT_FILE
                    fi
                fi
            fi
        done
        echo "========================================" >> $OUTPUT_FILE
    done
    echo "Report saved to $OUTPUT_FILE"
done
