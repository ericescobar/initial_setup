#!/bin/bash

# Update Hostname
function update_hostname() {
  echo -n "New Hostname [ENTER]: "
  read host_name
  sudo hostnamectl set-hostname "$host_name"
  echo "Hostname set"
}

# Set TZ PST
function update_timezone() {
  #Set TimeZone
  sudo ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
  echo "Timezone set"
}

# Install some tools
function install_tools() {
  sudo apt-get update
  sudo apt-get upgrade -y
  sudo apt-get install -y git vim curl zsh nmap rsync git screen python3 python3-pip ntp
  sudo pip3 install netifaces requests cheat twilio
}

# Install some tools
function install_twilio() {
  sudo mkdir -p /opt/
  sudo mkdir -p /opt/sms_notify
  sudo cp SMS_on_boot.py /opt/sms_notify/SMS_on_boot.py
  sudo cp sms_on_boot.service /etc/systemd/system/
  sudo cp sendsms.py /opt/sms_notify/
  sudo cp config.txt /opt/sms_notify/
  sudo systemctl enable sms_on_boot.service
  sudo systemctl start sms_on_boot.service
  echo "SMS Notify Enabled"
}

# Setup zsh and screen logging
function setup_zsh() {
  sudo apt-get install -y zsh
  sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
  chsh -s $(which zsh)
  cp custom_zshrc ~/.zshrc
  echo "export ZSH=$HOME/.oh-my-zsh" >> ~/.zshrc
  echo 'DISABLE_AUTO_UPDATE="true"' >> ~/.zshrc
  echo 'source $ZSH/oh-my-zsh.sh' >> ~/.zshrc
  cp custom_zsh-theme ~/.oh-my-zsh/themes/custom.zsh-theme
  . ~/.zshrc
  cp screenrc ~/.screenrc
  mkdir ~/logs
}

# Help menu
function display_help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  update  : Update packages"
  echo "  tools   : Install tools (git, vim, curl)"
  echo "  zsh     : Setup zsh"
  echo "  all     : Run all of the above"
}


# Check command line arguments and execute accordingly
for arg in "$@"; do
  case $arg in
    timezone)
      update_timezone
      ;;
    hostname)
      update_hostname
      ;;
    twilio)
      install_twilio
      ;;
    tools)
      install_tools
      ;;
    zsh)
      setup_zsh
      ;;
    all)
      install_tools
      install_twilio
      setup_zsh
      update_timezone
      update_hostname
      ;;
    help|--help|-h)
      display_help
      exit 0
      ;;
    *)
      echo "Invalid option: $arg"
      echo "Available options: update, tools, zsh, timezone, twilio, hostname, all"
      exit 1
      ;;
  esac
done
