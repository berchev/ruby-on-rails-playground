#!/usr/bin/env bash

# Install ruby
[ "$(ruby -v | awk '{print $2}')" == "2.6.3p62" ] || {
  source /home/vagrant/.bash_profile 
  rbenv install 2.6.3 
  rbenv global 2.6.3
}

# Install Rails
gem list -i rails || {
  gem install rails
}

# Update gems
gem update

