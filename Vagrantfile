# -*- mode: ruby -*-

# vi: set ft=ruby :
require "yaml"
require "json"

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'libvirt'

master_ip = "192.168.205.10"

boxes = [
    {
        :name => "h0",
        :eth1 => master_ip,
        :mem => "2048",
        :cpu => "2",
        :interface => "eth1"
    },
    {
        :name => "h1",
        :eth1 => "192.168.205.11",
        :mem => "2048",
        :cpu => "2",
        :interface => "eth1"
    },

    {
      :name => "h2",
      :eth1 => "192.168.205.12",
      :mem => "2048",
      :cpu => "2",
      :interface => "eth1"
  },
  {
      :name => "h3",
      :eth1 => "192.168.205.13",
      :mem => "2048",
      :cpu => "2",
      :interface => "eth1"
  },

]

Vagrant.configure(2) do |config|

  config.vm.box = "generic/ubuntu2004"


  # Turn off shared folders
  config.vm.synced_folder "hyperledger-fabric-cluster-stack", "/srv", id: "vagrant-root", disabled: true


  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y git curl
    curl -o bootstrap-salt.sh -L https://bootstrap.saltstack.com
    
    SHELL


  boxes.each do |opts|
    config.vm.define opts[:name] do |config|
      config.vm.hostname = opts[:name]


      config.vm.provider :libvirt do |v|
        v.memory = opts[:mem]
        v.cpus = opts[:cpu]
        end

      config.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--name", opts[:name]]
        v.customize ["modifyvm", :id, "--memory", opts[:mem]]
        v.customize ["modifyvm", :id, "--cpus", opts[:cpu]]
      end


      config.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y git curl python3-pip 
      curl -o bootstrap-salt.sh -L https://bootstrap.saltstack.com
      
      SHELL

      master_file=YAML.load_file('hyperledger-fabric-cluster-stack/templates/master.tpl').to_json
      minion_file=File.read('hyperledger-fabric-cluster-stack/templates/minion-vagrant.tpl')

      puts minion_file
      if opts[:name] == "h0"
        config.vm.provision "shell", inline: <<-SHELL
        sh bootstrap-salt.sh -x python3 -F -M -i '#{opts[:name]}' -A '#{opts[:eth1]}' -J '#{master_file}'
      SHELL
        
        
      end

      config.vm.provision "file", source: "hyperledger-fabric-cluster-stack/templates/minion-vagrant.sh", destination: "$HOME/minion-vagrant.sh"
      config.vm.provision "file", source: "hyperledger-fabric-cluster-stack/templates/minion.tpl", destination: "$HOME/minion.tpl"

      config.vm.provision "shell", inline: <<-SHELL
        bash minion-vagrant.sh #{opts[:name]} #{master_ip} #{opts[:interface]}
      SHELL
      


      config.vm.network :private_network, ip: opts[:eth1]
    end
  end
end