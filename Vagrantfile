# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.box = "andrewwardrobe/fedora-kde"

  config.vm.provider "virtualbox" do |vb|
   # Display the VirtualBox GUI when booting the machine
    vb.gui = true
   # Customize the amount of memory on the VM:
    vb.memory = "4096"
    vb.cpus = 2
    vb.customize ["modifyvm", :id, "--vram", "64"]
    #Two Monitor Setup
    vb.customize ["modifyvm", :id, "--monitorcount", "2"]
  end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-'SHELL'
	 puppet apply /vagrant/manifests/main.pp
	 if [ -e /vagrant/data.yaml ]; then
       /vagrant/scripts/setup.rb /vagrant/data.yaml
	 fi
   sudo -u andrew mkdir -p /home/andrew/.RubyMine2017.3/config/
   sudo -u andrew mkdir -p /home/andrew/.IntelliJIdea2017.3/config/
   
   sudo -u andrew cp /vagrant/keys/rubymine.key /home/andrew/.RubyMine2017.3/config/rubymine.key
   sudo -u andrew cp /vagrant/keys/idea.key /home/andrew/.IntelliJIdea2017.3/config/idea.key
   sudo -u andrew cp /vagrant/devops.rsa /home/andrew/.ssh
   sudo -u andrew cp /vagrant/vagrant.rsa /home/andrew/.ssh
   chmod -R 700 /home/andrew/.ssh
   
   
  SHELL
end
