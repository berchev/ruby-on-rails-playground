Vagrant.configure("2") do |config|
  config.vm.box = "berchev/xenial64_x11"
  config.vm.provision :shell, path: "scripts/provision.sh"
  config.vm.network :forwarded_port, guest: 3000, host: 3000 # Puma webserver
end
