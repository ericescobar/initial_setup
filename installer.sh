#!/bin/bash

# Update Hostname
function update_hostname() {
  echo -n "New Hostname [ENTER]: "
  read host_name
  sudo hostnamectl set-hostname "$host_name"
  echo "Hostname set"
  return 0
}

# Set TZ PST
function update_timezone() {
  # Set TimeZone
  sudo ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
  echo "Timezone set"
  return 0
}

# Install some tools
function install_tools() {
  sudo apt-get update
  sudo apt-get upgrade -y
  sudo apt-get install -y git vim curl zsh nmap rsync git screen python3 python3-pip python3-venv ntp
  # Note: Python packages should be installed in virtual environments
  # Use pipx for command-line tools that need global access
  sudo apt-get install -y pipx
  pipx ensurepath
  pipx install cheat
  echo "Tools installed"
  echo "Note: Python packages like netifaces, requests, twilio should be installed in virtual environments"
  return 0
}

# Install Twilio
function install_twilio() {
  # Make sure config.txt is filled in before doing anything - an empty config
  # installs fine but every SMS would fail at runtime (no creds / numbers).
  SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  if [ ! -f "$SCRIPT_DIR/config.txt" ] || ! grep -q '[^[:space:]]' "$SCRIPT_DIR/config.txt"; then
    echo "Error: $SCRIPT_DIR/config.txt is empty or missing."
    echo "Create it from the template, then fill in your values:"
    echo "  cp $SCRIPT_DIR/config.txt.sample $SCRIPT_DIR/config.txt"
    echo "Expected format (one quoted value per line, no blank or comment lines):"
    echo '  "DeviceID"'
    echo '  "+15551234567,+15557654321"'
    echo '  "TwilioAccountSID"'
    echo '  "TwilioAuthToken"'
    echo '  "+15550001111"'
    return 1
  fi

  sudo apt-get update
  sudo apt-get install -y git python3 python3-pip python3-venv python3-dev build-essential
  
  # Create directory structure
  sudo mkdir -p /opt/sms_notify
  
  # Create virtual environment
  sudo python3 -m venv /opt/sms_notify/venv
  
  # Install packages in virtual environment
  sudo /opt/sms_notify/venv/bin/pip install --upgrade pip
  sudo /opt/sms_notify/venv/bin/pip install netifaces requests twilio
  
  # Copy files (using script directory as base)
  SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  sudo cp "$SCRIPT_DIR/SMS_on_boot.py" /opt/sms_notify/SMS_on_boot.py
  sudo cp "$SCRIPT_DIR/sms_on_boot.service" /etc/systemd/system/
  sudo cp "$SCRIPT_DIR/sendsms.py" /opt/sms_notify/
  sudo cp "$SCRIPT_DIR/config.txt" /opt/sms_notify/
  
  # Set permissions
  sudo chmod +x /opt/sms_notify/SMS_on_boot.py
  
  # Enable and start service
  sudo systemctl daemon-reload
  sudo systemctl enable sms_on_boot.service
  sudo systemctl start sms_on_boot.service
  echo "SMS Notify Enabled"
  return 0
}

# Install time fixer (HTTP bootstrap + NTP sync, on boot and every 3 hours)
function install_time_fixer() {
  sudo apt-get update
  # ntpsec       : the NTP daemon for continuous time keeping
  # ntpsec-ntpdate: the one-shot ntpdate client used by time_fixer.sh
  sudo apt-get install -y ntpsec ntpsec-ntpdate curl

  # Enable the NTP daemon so time stays disciplined between fixer runs.
  # Service name is "ntpsec" on modern Debian, "ntp" on older releases.
  sudo systemctl enable --now ntpsec 2>/dev/null \
    || sudo systemctl enable --now ntp 2>/dev/null \
    || echo "Warning: could not enable an NTP daemon (ntpsec/ntp)"

  # Create directory structure
  sudo mkdir -p /opt/time_fixer

  # Copy files (using script directory as base)
  SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  sudo cp "$SCRIPT_DIR/time_fixer.sh" /opt/time_fixer/time_fixer.sh
  sudo cp "$SCRIPT_DIR/time_fixer.service" /etc/systemd/system/
  sudo cp "$SCRIPT_DIR/time_fixer.timer" /etc/systemd/system/

  # Set permissions
  sudo chmod +x /opt/time_fixer/time_fixer.sh

  # Enable timer (boot + every 3 hours) and fix the clock once right now
  sudo systemctl daemon-reload
  sudo systemctl enable time_fixer.timer
  sudo systemctl start time_fixer.timer
  sudo systemctl start time_fixer.service
  echo "Time fixer installed (runs on boot and every 3 hours)"
  return 0
}

# Add current user to sudoers with NOPASSWD
function setup_sudoers() {
  current_user=$(whoami)
  echo "Adding $current_user to sudoers with NOPASSWD..."
  
  # Create a sudoers file for the user
  sudoers_file="/etc/sudoers.d/$current_user"
  sudo bash -c "echo '$current_user ALL=(ALL) NOPASSWD: ALL' > $sudoers_file"
  
  # Set proper permissions
  sudo chmod 0440 "$sudoers_file"
  
  # Verify the file is valid
  sudo visudo -c -f "$sudoers_file"
  if [ $? -eq 0 ]; then
    echo "Successfully added $current_user to sudoers with NOPASSWD"
  else
    echo "Error: Invalid sudoers configuration, removing file"
    sudo rm "$sudoers_file"
    exit 1
  fi
  return 0
}

# Setup zsh and screen logging
function setup_zsh() {
  sudo apt-get install -y zsh
  sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
  sudo chsh $USER -s $(which zsh)
  cp custom_zshrc ~/.zshrc
  echo "export ZSH=$HOME/.oh-my-zsh" >> ~/.zshrc
  echo 'DISABLE_AUTO_UPDATE="true"' >> ~/.zshrc
  echo 'source $ZSH/oh-my-zsh.sh' >> ~/.zshrc
  cp custom_zsh-theme ~/.oh-my-zsh/themes/custom.zsh-theme
  . ~/.zshrc
  cp screenrc ~/.screenrc
  mkdir ~/logs
  echo "ZSH setup complete"
  return 0
}

# Help menu
function display_help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  update    : Update packages (Deprecated)"
  echo "  tools     : Install tools (git, vim, curl, etc.)"
  echo "  zsh       : Setup zsh"
  echo "  timezone  : Update timezone"
  echo "  hostname  : Update hostname"
  echo "  twilio    : Install and configure Twilio for SMS notifications"
  echo "  time_fixer: Fix clock via HTTP then NTP on boot and every 3 hours"
  echo "  sudoers   : Add current user to sudoers with NOPASSWD"
  echo "  all       : Run all of the above"
  return 0
}

# Check if no arguments were provided and display help if true
if [ $# -eq 0 ]; then
  display_help
fi

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
    time_fixer)
      install_time_fixer
      ;;
    tools)
      install_tools
      ;;
    zsh)
      setup_zsh
      ;;
    sudoers)
      setup_sudoers
      ;;
    all)
      install_tools
      install_time_fixer
      install_twilio
      setup_zsh
      setup_sudoers
      update_timezone
      update_hostname
      exit 0
      ;;
    help|--help|-h)
      display_help
      ;;
    *)
      echo "Invalid option: $arg"
      echo "Available options: update (Deprecated), tools, zsh, timezone, twilio, time_fixer, hostname, sudoers, all"
      exit 1
      ;;
  esac
done
