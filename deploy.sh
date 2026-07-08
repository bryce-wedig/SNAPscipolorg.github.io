#!/bin/bash

set -e

# Load chruby
source $(brew --prefix chruby)/share/chruby/chruby.sh

# Optionally load auto-switcher
source $(brew --prefix chruby)/share/chruby/auto.sh

# Reload shell configuration 
source ~/.zshrc

# Activate correct Ruby version
chruby 3.4.1

# Deploy
bundle exec jekyll serve
