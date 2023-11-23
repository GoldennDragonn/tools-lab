#!/bin/bash

while true; do
    echo "Enter the number of Master Nodes:"
    read num_masters
    
    if [ "$num_masters" -eq 1 ]; then
        echo "Enter Single Master node IP:"
        read master_ip
        echo -e "[single_master_node]\n$master_ip" > inventory.yaml
        break
    elif [ "$num_masters" -eq 2 ]; then
        echo "1 or 3 and more Masters required, please choose again."
    elif [ $(($num_masters % 2)) -eq 1 ]; then
        echo "Enter the Main Master IP:"
        read master_ip
        echo -e "[main_master_node]\n$master_ip" > inventory.yaml
        for ((i=2; i<=$num_masters; i++)); do
            echo "Enter the ${i}th Master IP:"
            read sec_master_ip
            if [ $i -eq 2 ]; then
                echo -e "\n[sec_master_nodes]" >> inventory.yaml
            fi
            echo $sec_master_ip >> inventory.yaml
        done
        break
    else
        echo "Please enter an odd number of Master Nodes."
    fi
done
