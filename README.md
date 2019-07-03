# ruby-on-rails-playground

Vagrant VM equipped with all needed configuration to play with ruby on rails

## Installed packages and configuration
- rbenv
- ruby-build
- ruby 2.6.3p62
- rails 5.2.3
- updated gems
- mysql-server 5.7 (configured to listen on all IP addresses)
- Guest port 3000 forwarded to Host 3000 (Rails Puma server)

## Requirements
- [Virtualbox installed](https://www.virtualbox.org/)
- [Vagrant installed](https://www.vagrantup.com/intro/getting-started/install.html)

## How to use?
- `git clone https://github.com/berchev/ruby-on-rails-playground.git`
- `cd ruby-on-rails-playground`
- `vagrant up`
- `vagrant ssh`

