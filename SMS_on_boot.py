#!/opt/sms_notify/venv/bin/python3
import sendsms
import time
import sys
import requests
import subprocess
import netifaces
import socket

#######################
# Network connectivity check
#######################
def wait_for_network(max_wait=300, check_interval=5):
    """Wait for network connectivity with timeout"""
    start_time = time.time()
    while time.time() - start_time < max_wait:
        try:
            # Try to connect to a reliable host
            socket.create_connection(("8.8.8.8", 53), timeout=3)
            return True
        except OSError:
            time.sleep(check_interval)
    return False

#######################
# Check Interfaces
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
                address_list.append(addrs[netifaces.AF_INET][0]['addr'])
            except:
                address_list.append('None')
    return address_list, interface_list

######################
# Check Public IP
######################
def CheckPublicIP():
    publicURLs = ['http://ipecho.net/plain', 'http://ip.42.pl/raw','http://ipinfo.io/ip']
    for URL in publicURLs:
        try:
            publicReqIP = requests.get(URL, timeout=10)
            if publicReqIP.status_code == 200:
                publicIP = publicReqIP.text
                break
        except:
            numURLs = len(publicURLs)
            publicIP = 'Unable to determine external IP from %s URLs internet may be down.' % (numURLs)
    publicIP = publicIP.strip(' \t\n\r')
    return publicIP

####################
# Send SMS with retry
####################
def send_sms_with_retry(message, max_retries=5):
    """Send SMS with exponential backoff retry"""
    retry_delay = 2
    
    for attempt in range(max_retries):
        try:
            sendsms.sms(message)
            print(f"SMS sent successfully on attempt {attempt + 1}")
            return True
        except Exception as e:
            if attempt < max_retries - 1:
                print(f"SMS send failed on attempt {attempt + 1}, retrying in {retry_delay} seconds...")
                print(f"Error: {e}")
                time.sleep(retry_delay)
                retry_delay *= 2  # Exponential backoff
            else:
                print(f"SMS send failed after {max_retries} attempts")
                print(f"Final error: {e}")
                return False
    return False

####################
# Main execution
####################
def main():
    # Wait for network connectivity
    print("Waiting for network connectivity...")
    if not wait_for_network():
        print("Network connectivity timeout after 5 minutes")
        sys.exit(1)
    
    print("Network is up, gathering information...")
    
    # Small delay to ensure all interfaces are fully up
    time.sleep(2)
    
    try:
        publicIP = CheckPublicIP()
        address_list, interface_list = CheckInterfaces()
        
        message = 'Public IP: %s' % (publicIP)
        i = 0
        total_interfaces = len(interface_list)
        while i < total_interfaces:
            message += "\n%s: %s" % (interface_list[i], address_list[i])
            i = i + 1
        
        print("Network information gathered:")
        print(message)
        
        # Send SMS with retry logic
        if send_sms_with_retry(message):
            print("SMS notification sent successfully")
            sys.exit(0)
        else:
            print("Failed to send SMS notification")
            sys.exit(1)
            
    except Exception as e:
        print(f"Error occurred: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()% 
