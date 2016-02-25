# -*- mode: ruby -*-

NAME = File.basename(File.dirname(__FILE__)).gsub(/[^\w]/, '')

DEPS = <<SCRIPT
apt-get -y install vim
apt-get -y install bundler
SCRIPT

BUNDLES = <<SCRIPT
pushd /vagrant
bundle install
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/vivid64"
  config.vm.hostname = NAME

  config.vm.provision :shell, inline: DEPS, keep_color: true
  config.vm.provision :shell, inline: BUNDLES, keep_color: true, privileged: false

  config.vm.network "forwarded_port", guest: 4000, host: 4000

  config.vm.provider "virtualbox" do |vb|
    vb.name = NAME
    vb.memory = 1024
    vb.gui = false
  end
end