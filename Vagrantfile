Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-22.04"

  # Define the node1
  config.vm.define "node1" do |node1|
    node1.vm.hostname = "node1"
    node1.vm.network "private_network", ip: "192.168.56.101"
    node1.vm.provider "virtualbox" do |v|
      v.memory = 4096
      v.cpus = 2
    end
    node1.vm.provision "shell", path: "node_script-no-docker.sh"
  end

  # Define the node2
  config.vm.define "node2" do |node2|
    node2.vm.hostname = "node2"
    node2.vm.network "private_network", ip: "192.168.56.102"
    node2.vm.provider "virtualbox" do |v|
      v.memory = 4096
      v.cpus = 2
    end
    node2.vm.provision "shell", path: "node_script-no-docker.sh"
  end

  # Define the node3
  config.vm.define "node3" do |node3|
    node3.vm.hostname = "node3"
    node3.vm.network "private_network", ip: "192.168.56.103"
    node3.vm.provider "virtualbox" do |v|
      v.memory = 4096
      v.cpus = 2
    end
    node3.vm.provision "shell", path: "node_script-no-docker.sh"
  end

  # Define the node4
  config.vm.define "node4" do |node4|
    node4.vm.hostname = "node4"
    node4.vm.network "private_network", ip: "192.168.56.104"
    node4.vm.provider "virtualbox" do |v|
      v.memory = 4096
      v.cpus = 4
    end
    node4.vm.provision "shell", path: "node_script-no-docker.sh"
  end
  # # Define the node4
  # config.vm.define "deploy" do |node4|
  #   node4.vm.hostname = "deploy"
  #   node4.vm.network "private_network", ip: "192.168.56.104"
  #   node4.vm.provider "virtualbox" do |v|
  #     v.customize ["modifyvm", :id, "--memory", "1024"]
  #     v.customize ["modifyvm", :id, "--cpus", "1"]
  #   end
  #   node4.vm.provision "shell", path: "node_script-docker.sh"
  # #   node4.vm.provision "shell", inline: "sudo apt-get update && sudo apt-get install -y ansible"
  # end
end
