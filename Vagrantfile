## VARIABLES
VM_IP = "192.168.56.110"
VM_NAME = "LFS-builder"

MEM = 4096
CORE = 4

Vagrant.configure("2") do |config|
  config.vm.box = "archlinux/archlinux"
  
  config.vm.define VM_NAME do |controller|
    controller.vm.hostname = VM_NAME
    controller.vm.provider "virtualbox" do |v|
      v.memory = MEM
      v.cpus = CORE
      v.name = VM_NAME
    end
    controller.vm.network "private_network", type: "static", ip: VM_IP
    controller.vm.synced_folder ".", "/vagrant", type: "virtualbox"
    controller.vm.provision "shell", inline: <<-SHELL
        sudo pacman -Syu --noconfirm
        sudo pacman -S bison gcc make patch perl python3 texinfo
    SHELL
  end
end