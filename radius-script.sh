#!/bin/bash

#./namespace.sh
#./intup.sh

LIVE_IP=172.30.230.1
VOD_IP=172.30.222.1
INTERNET_IP=172.30.220.1
CLIENT_IP=172.30.234.31
ACCEL_IP=172.30.234.66
RADIUS_IP=172.30.234.67
POOL_ILV=$(ssh root@$ACCEL_IP accel-cmd ippool show | grep -w "pool-ILV" | awk '{print $3}')
POOL_IL=$(ssh root@$ACCEL_IP accel-cmd ippool show | grep -w "pool-IL" | awk '{print $3}')
POOL_IV=$(ssh root@$ACCEL_IP accel-cmd ippool show | grep -w "pool-IV" | awk '{print $3}')
POOL_I=$(ssh root@$ACCEL_IP accel-cmd ippool show | grep -w "pool-I" | awk '{print $3}')


echo -e "\n \e[0;36m Test Case 1 \e[0m \n"
ssh root@$ACCEL_IP "radtest user-ILV xflow 172.16.26.74 18128 xflow"
sleep 20

echo -e "\n \e[0;34m *************************************** \e[0m \n"

echo -e "\n \e[0;36m Test Case 2 \e[0m \n"
ssh root@$ACCEL_IP "radtest user-D xflowresearch 172.16.26.74 18128 xflow"
sleep 20

echo -e "\n \e[0;34m *************************************** \e[0m \n"

echo -e "\n \e[0;36m Test Case 3 \e[0m \n"
ssh root@$ACCEL_IP "radtest user-ILV xflow 172.16.26.74 18128 xflow"
sleep 20

echo -e "\n \e[0;34m *************************************** \e[0m \n"

echo -e "\n \e[0;36m Test Case 4 \e[0m \n"
radtest user-ILV xflow 172.16.26.74 18128 xflow
sleep 20
radtest user-ILV xflowresearch 172.16.26.74 18128 xflow
sleep 20

echo -e "\n \e[0;34m *************************************** \e[0m \n"

echo -e "\n \e[0;36m Test Case 5 \e[0m \n"
ssh root@$ACCEL_IP "sed -i '8s/radius/#radius/' /etc/accel-ppp.conf"
ssh root@$ACCEL_IP "sed -i '39s/any-login=0/any-login=1/' /etc/accel-ppp.conf"
ssh root@$ACCEL_IP "sed -i '40s/noauth=0/noauth=1/' /etc/accel-ppp.conf"
ssh root@$ACCEL_IP "radtest user-D xflowresearch 172.16.26.74 18128 xflow"
sleep 20
ssh root@$ACCEL_IP "sed -i '8s/#radius/radius/' /etc/accel-ppp.conf"
ssh root@$ACCEL_IP "sed -i '39s/any-login=1/any-login=0/' /etc/accel-ppp.conf"
ssh root@$ACCEL_IP "sed -i '40s/noauth=1/noauth=0/' /etc/accel-ppp.conf"

echo -e "\n \e[0;34m *************************************** \e[0m \n"

echo -e "\n \e[0;36m Test Case 6 \e[0m \n"
echo root@$CLIENT_IP
total_ns=$(ssh root@$CLIENT_IP ip netns list|head -1|grep -o '[0-9] ')
echo $total_ns
for i in `seq 1 $total_ns`;
do
ssh root@$CLIENT_IP "ip netns exec ns$i pon d$i"
done
sleep 5
ssh root@$ACCEL_IP "accel-cmd show stat"
for i in `seq 1 $total_ns`;
do
ssh root@$CLIENT_IP "ip netns exec ns$i poff d$i"
done
sleep 5

echo -e "\n \e[0;34m *************************************** \e[0m \n"

echo -e "\n \e[0;36m Test Case 7 \e[0m \n"
ssh root@$RADIUS_IP "/etc/init.d/freeradius stop"
ssh root@$RADIUS_IP "freeradius -X"
sleep 2
ssh root@$ACCEL_IP "/etc/init.d/accel-ppp restart"
sleep 5
echo "dont know how to share debugging mode in radius to share here"

echo -e "\n \e[0;34m *************************************** \e[0m \n"

echo -e "\n \e[0;36m Test Case 8 \e[0m \n"
ssh root@$RADIUS_IP "sed -i '175,180 s/^/#/' /etc/freeradius/clients.conf"
ssh root@$ACCEL_IP "/etc/init.d/accel-ppp restart"
echo "dont know how to share debugging mode in radius to share here"
ssh root@$RADIUS_IP "sed -i '175,180 s/^##*//' /etc/freeradius/clients.conf"

echo -e "\n \e[0;34m *************************************** \e[0m \n"

echo -e "\n \e[0;36m Test Case 9 \e[0m \n"


