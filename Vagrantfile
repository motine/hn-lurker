# -*- mode: ruby -*-

NAME = File.basename(File.dirname(__FILE__)).gsub(/[^\w]/, '')

DEPS = <<SCRIPT
apt-get -y install vim jq
apt-get -y install couchdb
apt-get -y install bundler

# make sure couchdb is accessible from the outside and CORS is enabled
# sed -i 's/^;bind_address.*$/bind_address = 0.0.0.0/' /etc/couchdb/local.ini
echo '[httpd]'                >> /etc/couchdb/local.ini
echo 'bind_address = 0.0.0.0' >> /etc/couchdb/local.ini
echo 'enable_cors = true'     >> /etc/couchdb/local.ini
echo                          >> /etc/couchdb/local.ini
echo '[cors]'                 >> /etc/couchdb/local.ini
echo 'origins = *'            >> /etc/couchdb/local.ini
systemctl restart couchdb
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

  config.vm.network "forwarded_port", guest: 5984, host: 5984

  config.vm.provider "virtualbox" do |vb|
    vb.name = NAME
    vb.memory = 1024
    vb.gui = false
  end
end


