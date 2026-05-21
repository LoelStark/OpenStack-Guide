#!/bin/bash

# Create project
openstack project create --description "Student Project" student-project

# Create user
openstack user create --password student123 student-user

# Add user to project with member role
openstack role add --project student-project --user student-user member

# Download Cirros image
wget http://download.cirros-cloud.net/0.6.2/cirros-0.6.2-x86_64-disk.img

# Upload image to OpenStack in QCOW2 format
openstack image create "cirros" \
--file cirros-0.6.2-x86_64-disk.img \
--disk-format qcow2 \
--container-format bare \
--public

# Verify image
openstack image list


# Create network
openstack network create student-network

# Create subnet
openstack subnet create student-subnet \
--network student-network \
--subnet-range 192.168.88.0/24


# Create router
openstack router create student-router

# Plug internal subnet into router
openstack router add subnet student-router student-subnet

# Plug router into external/provider network
openstack router set --external-gateway public student-router


# Check existing flavors
openstack flavor list

# Create new micro flavor
openstack flavor create m1.nebula_micro \
--ram 512 \
--disk 5 \
--vcpus 1


# Create SSH keypair
openstack keypair create nebula-key > nebula-key.pem

# Set secure permissions on private key
chmod 600 nebula-key.pem

# Verify keypair
openstack keypair list

# Allow SSH (Port 22) from ANYWHERE
openstack security group rule create --proto tcp --dst-port 22 nebula_web_sg

# Allow HTTP (Port 80) from ANYWHERE
openstack security group rule create --proto tcp --dst-port 80 nebula_web_sg



# Create boot script
echo "#!/bin/sh" > boot.sh
echo "while true; do echo -e 'HTTP/1.0 200 OK\r\n\r\nHello Nebula Inc' | sudo nc -l -p 80 ; done &" >> boot.sh


# Launch instance
openstack server create nebula_web_01 \
--flavor m1.nebula_micro \
--image cirros-lab8 \
--network lab8_net \
--security-group nebula_web_sg \
--key-name nebula_key \
--user-data boot.sh

# Monitor build status
openstack server list


# Create floating IP from external network (public)
openstack floating ip create public
# Attach floating IP to instance
openstack server add floating ip nebula_web_01 <YOUR_FLOATING_IP>
# Attach floating IP to instance
openstack server add floating ip nebula_web_01 <YOUR_FLOATING_IP>
# SSH into instance
ssh -i nebula_key.pem cirros@<YOUR_FLOATING_IP>
# Test web service
curl http://<YOUR_FLOATING_IP>

