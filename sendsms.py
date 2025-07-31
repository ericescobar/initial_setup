#!/usr/bin/python3

#Importing stuff
import datetime
import re
def sms(sms_body):
	#Reading from config.txt
	import os
	config_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'config.txt')
	f = open(config_path,'r')
	lines = f.read().splitlines()
	DeviceID = re.findall(r'"([^"]*)"', lines[0])[0]
	twilio_account = re.findall(r'"([^"]*)"', lines[2])[0]
	twilio_token = re.findall(r'"([^"]*)"', lines[3])[0]
	twilio_from = re.findall(r'"([^"]*)"', lines[4])[0]
	phoneNumbers = re.findall(r'"([^"]*)"', lines[1])[0]
	phoneNumbers = phoneNumbers.split(",")
	f.close()

	#Checking & formatting time
	timedate = datetime.datetime.now()
	tdate = timedate.strftime('%I:%M%p')

	#Format Message header you want to send
	sms_message = '%s: %s \n%s' % (DeviceID,tdate,sms_body)


	#Sending sms to every number in config.txt
	for phoneNumber in phoneNumbers:
		from twilio.rest import Client
		client = Client(twilio_account, twilio_token)
		message = client.messages.create(
               		to=phoneNumber,
               		from_=twilio_from,
               		body=sms_message,
       			)
