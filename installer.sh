#!/bin/bash
#passwd
#echo -n "New Hostname [ENTER]: "
#read host_name
#sudo hostnamectl set-hostname "$host_name" 
#echo "Hostname set"

#Set TimeZone
sudo ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
echo "Timezone set"

#Set Message of the day
#rm -rf /etc/update-motd.d/*
#echo "----------------------------------------\nJurassic Park, System Security Interface\nVersion 4.0.5, Alpha E\nReady...\n----------------------------------------" > "/etc/update-motd.d/00-custom-motd"
#chmod +x /etc/update-motd.d/00-custom-motd
#sudo sed -i '/noupdate/s/^/#/g' /etc/pam.d/sshd

#Set up sms on boot
sudo mkdir -p /opt/
sudo mkdir -p /opt/sms_notify
sudo cp SMS_on_boot.py /opt/sms_notify/SMS_on_boot.py
sudo cp sms_on_boot.service /etc/systemd/system/
sudo cp sendsms.py /opt/sms_notify/
sudo cp config.txt /opt/sms_notify/
sudo systemctl enable sms_on_boot.service
sudo systemctl start sms_on_boot.service
echo "SMS Notify Enabled"

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y \
curl \
zsh \
nmap \
rsync \
git \
screen \
python3 \
python3-pip \
vim \
ntp \

sudo pip3 install \
netifaces \
requests \
cheat \
twilio

#mkdir -p ~/.ssh
#echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAD9QCnJzalUg7PaVW+hZgkzrHQZXURr7plSsbMNPxoTtijQbvtgqC5WMXNZIUrXZGKmb4nkg73XsXfFUuVq9prcV9AZ16aacBFCtDJd2i3k2fm+muLvNf4vrBKIkEMHdNT/HnU7+sBTk4qnj4APqYst59Ys1cYJwEcPMV+xlIPejrvbKCxeNVPw2L4KXKJGqI+xHed4Btf+zyzKK3UVDUNQoOgCGQRK4i2kZZy9T4ETe78s0KyN7qUTgVLWyD/t7xbSTSAaOKmQP/uGh/8ru1GYG9j3GimzEaaWTroAZ0fnCnc6YuAAjwOiP6VRQ3Y2jW4QviMGCI7ivkmyZ81oqnfJB1w5xgdrUIl1lyRb5pDuTaszpcIma5G2Vy4UzydadnKblEn/3LfS8RffMhT2R+RxytOKsFW5LtPqbfUfk8HPJKv2JXYH+kg1Y8v9ulpatR3o4iC14Hii4wZx8023feLPRpDzSzrkohNliLA1YinxtTEK0MaCYcbRvUbq3SjJjsr6eZ4Z2MHUyGylCq3znUPhX0+0kBn9m+BdOy/E/+U3zLKTV1H7I5m27PK//HUImYXGi1uU9ATvw/D6Zgf6tVC5bI6FGDStBMi1fNFm4wereeTdgH2C3zIwtvC0w9ngMJT+iNKw4UDnR2+ruY0aHqqQYwBPkGEwtbE4br/aSahJ6s/68mdTXsXSqDo5Yd7addX6tuPWg1QQqBtztsNMNycHEvkbutzYY6qAXeGkoEemeeTQIzoK11cNoEnau2Pz1yWNrSYk9g88qj0YPi61E4kT0woBLwwaRdStslmb2dZgUQOTgfUrmM8x82zxz8BBBYdQA5EFyuCQRtZK9DAUnGDrzhyc7oEitpRvuI0QCAsRfZzDTLFMbcHhD536CMRiZpUmd3WfZb3iMPbjwqaCxIHrplXtVeMhJ35WGeZonWuos42eN7p6sJO1gp2xmvsNUHMR6NIM4xTM86o1H9nZeTVV0tNOt3HmNp7VdqNg7MUN43769efvaguQLr5ejoefEl3KXDdH8HSAxrmUsA/TChLlhVH8pFhRzsh/EfGMrCOqy2ZtrxCyP/qfZK52P7qf8VBsNiKZGXxi1d5eaXgNfKmnZYpRAuSvyWf88goUEQZU6hVV8eqPzeMPjE/4p3O8BGQ79jgSZk+wE1Gp6G4VCfRKXwQlKWKdLfulsoFj8kIt+ZXIPljuy3plZDAsxM+RLjqodap5A/7Bb9V9sg2SB/klieSFD3KOo5pHqh245R9AfcH5d1j3R8Sd0ofb/gbj6LLxwusJOE3DGVMfQPcbuMwEAIJ4Nogdkh8X0wBkKDvyrsbbG9kNK7XX4ism3axmNEC5EqaS8Qp PersonalProjects" > ~/.ssh/authorized_keys
#chmod 644 ~/.ssh/authorized_keys
#echo "SSH Key Installed"
#sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
#chsh -s $(which zsh)
#cp custom_zshrc ~/.zshrc
#echo "export ZSH=$HOME/.oh-my-zsh" >> ~/.zshrc
#echo 'DISABLE_AUTO_UPDATE="true"' >> ~/.zshrc
#echo 'source $ZSH/oh-my-zsh.sh' >> ~/.zshrc
#cp custom_zsh-theme ~/.oh-my-zsh/themes/custom.zsh-theme
#. ~/.zshrc
#echo "ZSH Installed"
#alias history="history -i"
