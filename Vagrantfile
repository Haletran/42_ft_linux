## VARIABLES
VM_IP = "192.168.56.110"
VM_NAME = "LFS-builder"

MEM = 4096
CORE = 6
LFS_DISK_SIZE = "70GB"
 
Vagrant.configure("2") do |config|
    config.vm.box = "debian/bookworm64"
  
    config.vm.define VM_NAME do |controller|
    controller.vm.hostname = VM_NAME
    controller.vm.provider "virtualbox" do |v|
        v.memory = MEM
        v.cpus = CORE
        v.name = VM_NAME
    end
    controller.vm.disk :disk, size: LFS_DISK_SIZE, name: "extra_storage1"
    controller.vm.network "private_network", type: "static", ip: VM_IP
    controller.vm.synced_folder ".", "/vagrant", type: "virtualbox"
    controller.vm.provision "shell", inline: <<-SHELL
            apt-get update
            apt-get install -y bison gcc make patch perl python3 texinfo parted gawk g++
            bash /vagrant/scripts/check_requirements.sh
    SHELL
end
end
