#!/usr/bin/python3
import sendsms
import time
import sys
import requests
import subprocess
import netifaces
time.sleep(5)
#######################
#Check Interfaces
#######################
def CheckInterfaces():
	interfaces = netifaces.interfaces()
	interface_list = []
	address_list = []
	for interface in interfaces:
		if interface != 'lo':
			interface_list.append(interface)
			try:
				addrs = netifaces.ifaddresses(interface)
				addrs[netifaces.AF_INET]
				#gws=netifaces.gateways()
				#print gws['default'][netifaces.AF_INET][0]
				address_list.append(addrs[netifaces.AF_INET][0]['addr'])
			except:
				address_list.append('None')
				#print addrs[netifaces.AF_INET][0]['netmask']
	return address_list, interface_list

######################
#Check Public IP
######################
def CheckPublicIP():
	#Public URLs that return your public facing IP address
	publicURLs = ['http://ipecho.net/plain', 'http://ip.42.pl/raw','http://ipinfo.io/ip']
	#Try each URL in the list
	for URL in publicURLs:
	#Try each URL until on passes with a 200 http code
		try:
			publicReqIP=requests.get(URL)
			if publicReqIP.status_code == 200:
				publicIP = publicReqIP.text
				#Break out of loop if one comes back
				break
		except:
			numURLs= len(publicURLs)
			publicIP='Unable to determine external IP from %s URLs internet may be down.' % (numURLs)
		#Strip out any spaces, newlines, tabs, that stuff
	publicIP=publicIP.strip(' \t\n\r')
	return publicIP
####################
#Format it all
####################
try:
	publicIP = CheckPublicIP()
	address_list,interface_list = CheckInterfaces()
	message = 'Public IP: %s' % (publicIP)
	i=0
	total_interfaces = len(interface_list)
	while i < total_interfaces:
		message += "\n%s: %s" % (interface_list[i],address_list[i])
		i=i+1
	print(message)
	sendsms.sms(message)
except ValueError as e:
        print("Error message not sent.")
	print(e)
	time.sleep(3)
	sys.exit(1)
