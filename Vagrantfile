#!/usr/bin/env ruby

Vagrant.configure('2') do |config|
  config.vm.hostname = 'riemann'
  config.vm.box = ENV['VAGRANT_BOX'] || 'opscode_ubuntu-12.04_chef-11.2.0'
  config.vm.box_url = ENV['VAGRANT_BOX_URL'] || "https://opscode-vm.s3.amazonaws.com/vagrant/#{config.vm.box}.box"
  config.vm.network :private_network, ip: '33.33.33.10'

  config.vm.provision :shell do |shell|
    shell.inline = 'test -f $1 || (sudo apt-get update -y && touch $1)'
    shell.args = '/var/run/apt-get-update'
  end

  config.vm.provision :chef_solo do |chef|
    chef.run_list = [
      'recipe[riemann::default]'
    ]
  end
end
