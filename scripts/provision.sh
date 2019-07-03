#!/usr/bin/env bash

#######################
# Function definition #
#######################

funcPermissions()
{
	[ "$(stat -c "%U %G" $1)" == "vagrant vagrant" ] || {
           chown -R vagrant.vagrant $1
        }
}

######################
# Main script starts #
######################

# Debug mode enabled
set -x

# Frequently used paths defined as variables
RBENV_PATH="/home/vagrant/.rbenv"
RUBY_BUILD_PATH="/home/vagrant/.rbenv/plugins/ruby-build"
GEMRC_PATH="/home/vagrant/.gemrc"

# Fix locale problem
grep LC_ALL="en_US.UTF-8" /etc/environment || {
  echo 'LC_ALL="en_US.UTF-8"' >> /etc/environment
}

# Install the dependencies required for rbenv and ruby
for PACKAGE in autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev libsqlite3-dev libmysqlclient-dev nodejs
do
	dpkg -l ${PACKAGE} || {
          apt-get update
	  apt-get install -y ${PACKAGE}
	}
done

# Install MySQL Server in a Non-Interactive mode. Default root password will be "vagrant"
dpkg --get-selections | grep mysql-server- || {
  export DEBIAN_FRONTEND=noninteractive
  debconf-set-selections <<< 'mysql-server mysql-server/root_password password vagrant'
  debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password vagrant'
  apt-get update
  apt-get install -y mysql-server
}

# Configure MySQL to listen on all IPs, if not configured
grep "bind-address		= 0.0.0.0" /etc/mysql/mysql.conf.d/mysqld.cnf || {
  cp /etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf.bak
  cp /vagrant/conf/mysqld.cnf /etc/mysql/mysql.conf.d/
  systemctl restart mysql.service
}

# Install rbenv
[ -d ${RBENV_PATH} ] || {
  git clone https://github.com/rbenv/rbenv.git ${RBENV_PATH}
}

# Change permissions from root/root to vagrant/vagrant on .rbenv
funcPermissions ${RBENV_PATH}

# Check if .bash_profile exists and add some configuration
[ -f /home/vagrant/.bash_profile ] || {
  touch /home/vagrant/.bash_profile
  chown vagrant.vagrant /home/vagrant/.bash_profile
}

# Add rbenv to your path
grep '.rbenv/bin' /home/vagrant/.bash_profile || {
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' | sudo tee -a /home/vagrant/.bash_profile
} 

grep 'rbenv init -' /home/vagrant/.bash_profile || {
 echo 'eval "$(rbenv init -)"' | sudo tee -a /home/vagrant/.bash_profile
}

# Install ruby-build
[ -d ${RUBY_BUILD_PATH} ] || {
  git clone https://github.com/rbenv/ruby-build.git ${RUBY_BUILD_PATH}
}

# Change permissions of ruby-build from root/root to vagrant/vagrant on ruby-build
funcPermissions ${RUBY_BUILD_PATH}

# Turn off local documentation for all gems we install
[ -f ${GEMRC_PATH} ] || {
  > ${GEMRC_PATH}
}

grep 'gem: --no-document' ${GEMRC_PATH} || {
  echo 'gem: --no-document' | sudo tee -a ${GEMRC_PATH}	
}

# change permissions from root/root to vagrant/vagrant on .gemrc
funcPermissions $GEMRC_PATH

# Install ruby
[ "$(ruby -v | awk '{print $2}')" == "2.6.3p62" ] || {
  su - vagrant -c "source /home/vagrant/.bash_profile && rbenv install 2.6.3 && rbenv global 2.6.3"
}

# Install Rails
su - vagrant -c "gem list -i rails" || {
  su - vagrant -c "gem install rails"
}

# Update gems
su - vagrant -c "gem update"
