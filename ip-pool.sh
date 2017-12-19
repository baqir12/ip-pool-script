#!/bin/bash

#./namespace.sh
#./intup.sh


LIVE_IP=172.30.230.1
VOD_IP=172.30.222.1
INTERNET_IP=172.30.220.1
CLIENT_IP=172.30.234.31
ACCEL_IP=172.30.234.66
POOL_ILV=$(ssh root@$ACCEL_IP accel-cmd ippool show | grep -w "pool-ILV" | awk '{print $3}')
POOL_IL=$(ssh root@$ACCEL_IP accel-cmd ippool show | grep -w "pool-IL" | awk '{print $3}')
POOL_IV=$(ssh root@$ACCEL_IP accel-cmd ippool show | grep -w "pool-IV" | awk '{print $3}')
POOL_I=$(ssh root@$ACCEL_IP accel-cmd ippool show | grep -w "pool-I" | awk '{print $3}')

echo "pool-ILV = $POOL_ILV"
echo "pool-IL = $POOL_IL"
echo "pool-IV = $POOL_IV"
echo "pool-I = $POOL_I"

if [[ "$POOL_ILV" != "" && "$POOL_I" != "" && "$POOL_IV" != "" && "$POOL_IL" != "" ]]
then


total_ns=$(ssh root@$CLIENT_IP ip netns list|head -1|grep -o '[0-9] ')
echo $total_ns

echo "Test Case 1"
for i in `seq 1 $total_ns`;
do
ssh root@$CLIENT_IP "ip netns exec ns$i pon d$i"
done
ssh root@$ACCEL_IP "accel-cmd ippool show"
for i in `seq 1 $total_ns`;
do
pp=$(ssh root@$CLIENT_IP ip netns exec ns"$i" ifconfig| grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'|head -1)
echo $pp
done
for i in `seq 1 $total_ns`;
do
ssh root@$CLIENT_IP "ip netns exec ns$i poff d$i"
done


echo "************************************************************************************"


#echo "Test Case 2"
#array[0]=5
#for i in `seq 1 $total_ns`;do
#	ssh root@$CLIENT_IP "ip netns exec ns$i pon d$i"
#	user=$(ssh root@$CLIENT_IP "cat /etc/ppp/peers/d$i | grep -w 'user' ")
#	echo $user 
#	user=$(echo $user | awk -F' ' '{print $2}' )
#	echo $user
#	#user=$(ssh root@$CLIENT_IP "cat /etc/ppp/peers/d"\$i" |
#	#echo $user
#	echo one client is loaded 
#	if [[ "$user" == '"user-I"' ]]
#	then
#		array[$i-1]=$i
#	fi
#done
#for j in ${array[@]};do
#	echo -n "$j "
#done
##echo $array
#n_user_I=$(ssh root@$ACCEL_IP "accel-cmd show sessions match username user-ILV | wc -l")
#if [[ "$n_user_I" > "3"  ]]
#then
#	ssh root@$ACCEL_IP "accel-cmd ippool delete pool-I $POOL_I"
#	echo "all pool-I connected users are now disconnected"
#	ssh root@$ACCEL_IP "accel-cmd ippool add pool-I 10.10.10.1-2"
#	count=0
#	for i in "${array[@]}"
#	do
#		$((count++))
#		if [[ "count" < "3" ]]
#		then
#			ssh root@$CLIENT_IP "ip netns exec ns$i pon d$i"
#		fi
#	done
#	ssh root@$ACCEL_IP "accel-cmd show sessions"
#	echo "2 user-I clients should be connected"
#	ip netns exec ns"array[0]" poff
#	ssh root@$ACCEL_IP "accel-cmd show sessions"
#	echo "1 user-I client should be connected"
#	ip netns exec ns"array[0]" pon
#	ssh root@$ACCEL_IP "accel-cmd show sessions"
#	ssh root@$ACCEL_IP "accel-cmd ippool add pool-I 10.10.10.1-2"
#	ssh root@$ACCEL_IP "accel-cmd ippool add pool-I $POOL_I"
#	else
#		echo "Atleast 2 user-I users to be connected"
#	fi


echo "Test Case 2"

ssh root@$ACCEL_IP "accel-cmd ippool delete pool-ILV $POOL_ILV"
ssh root@$ACCEL_IP "accel-cmd ippool add pool-ILV 10.10.10.1-2"
for i in `seq 1 $total_ns`;do
old=$(ssh root@$CLIENT_IP "cat /etc/ppp/peers/d$i |awk '/"/,/"/ {print $2}'")
ssh root@$CLIENT_IP "sed -i 's/$old/\"user-ILV\"/g' /etc/ppp/peers/$i"
done
for i in `seq 1 $total_ns`;do
        ssh root@$CLIENT_IP "ip netns exec ns$i pon d$i"
done
ssh root@$ACCEL_IP "accel-cmd show sessions"
ssh root@$CLIENT_IP "ip netns exec ns$i poff d1"
ssh root@$ACCEL_IP "accel-cmd show sessions"
ssh root@$CLIENT_IP "ip netns exec ns$i pon d1"
ssh root@$ACCEL_IP "accel-cmd show sessions"
ssh root@$ACCEL_IP "accel-cmd ippool delete pool-ILV 10.10.10.1-2"
ssh root@$ACCEL_IP "accel-cmd ippool add pool-I $POOL_I"
for i in `seq 1 $total_ns`;
do
ssh root@$CLIENT_IP "ip netns exec ns$i poff d$i"
done

echo "************************************************************************************"

echo "Test Case 3"

ssh root@$ACCEL_IP "accel-cmd ippool delete pool-ILV $POOL_ILV"
ssh root@$ACCEL_IP "accel-cmd ippool add pool-ILV 10.10.10.1-1"
#ssh root@$ACCEL_IP "accel-cmd ippool add pool-ILV 10.10.11.1-1"
ssh root@$CLIENT_IP "ip netns exec ns1 pon d1"
ssh root@$CLIENT_IP "ip netns exec ns2 pon d2"
echo "one user must be connected"
ssh root@$ACCEL_IP "accel-cmd show sessions"
ssh root@$ACCEL_IP "accel-cmd ippool add pool-ILV 10.10.11.1-1"
ssh root@$CLIENT_IP "ip netns exec ns2 pon d2"
echo "now both should be connected"
ssh root@$ACCEL_IP "accel-cmd show sessions"
ssh root@$ACCEL_IP "accel-cmd ippool delete pool-ILV 10.10.11.1-1"
ssh root@$ACCEL_IP "accel-cmd ippool delete pool-ILV 10.10.10.1-1"
ssh root@$ACCEL_IP "accel-cmd ippool add pool-ILV $POOL_ILV"
for i in `seq 1 $total_ns`;
do
ssh root@$CLIENT_IP "ip netns exec ns$i poff d$i"
done

echo "************************************************************************************"

echo "Test Case 4"

ssh root@$ACCEL_IP "accel-cmd ippool delete pool-ILV $POOL_ILV"
ssh root@$ACCEL_IP "accel-cmd ippool add pool-ILV 10.10.10.1-1"
ssh root@$CLIENT_IP "ip netns exec ns1 pon d1"
ssh root@$ACCEL_IP "accel-cmd show sessions"
ssh root@$ACCEL_IP "accel-cmd ippool delete pool-ILV 10.10.10.1-1"
ssh root@$ACCEL_IP "accel-cmd ippool add pool-ILV 10.10.11.1-1"
ssh root@$CLIENT_IP "ip netns exec ns1 poff d1"
ssh root@$CLIENT_IP "ip netns exec ns1 pon d1"
ssh root@$ACCEL_IP "accel-cmd show sessions"
ssh root@$ACCEL_IP "accel-cmd ippool delete pool-ILV 10.10.11.1-1"
ssh root@$ACCEL_IP "accel-cmd ippool delete pool-ILV 10.10.10.1-1"
ssh root@$ACCEL_IP "accel-cmd ippool add pool-ILV $POOL_ILV"
for i in `seq 1 $total_ns`;
do
ssh root@$CLIENT_IP "ip netns exec ns$i poff d$i"
done

echo "************************************************************************************"

echo "Test Case 5"

for i in `seq 1 $total_ns`;
do
ssh root@$CLIENT_IP "ip netns exec ns$i pon d$i"
done
ssh root@$ACCEL_IP "accel-cmd show sessions"
for i in `seq 1 $total_ns`;
do
ssh root@$CLIENT_IP "ip netns exec ns$i poff d$i"
done
ssh root@$ACCEL_IP "accel-cmd ippool delete pool-ILV $POOL_ILV"
for i in `seq 1 $total_ns`;
do
ssh root@$CLIENT_IP "ip netns exec ns$i pon d$i"
done
ssh root@$ACCEL_IP "accel-cmd show sessions"
ssh root@$ACCEL_IP "accel-cmd ippool add pool-ILV $POOL_ILV"
for i in `seq 1 $total_ns`;
do
ssh root@$CLIENT_IP "ip netns exec ns$i poff d$i"
done


echo "************************************************************************************"

echo "Test Case 6"

echo "not done because database is to be changed by script. Will do it with help of sami"

echo "************************************************************************************"

echo "Test Case 7"

echo "not done because database is to be changed by script. Will do it with help of sami"

echo "************************************************************************************"

echo "Test Case 8"

ssh root@$ACCEL_IP "accel-cmd ippool delete pool-ILV $POOL_ILV"
ssh root@$ACCEL_IP "accel-cmd ippool add pool-ILV 10.10.10.1-1"
#ssh root@$ACCEL_IP "accel-cmd ippool add pool-ILV 10.10.11.1-1"
ssh root@$CLIENT_IP "ip netns exec ns1 pon d1"
ssh root@$CLIENT_IP "ip netns exec ns2 pon d2"
echo "one user must be connected"
ssh root@$ACCEL_IP "accel-cmd show sessions"
ssh root@$CLIENT_IP "ip netns exec ns2 poff d2"
ssh root@$ACCEL_IP "accel-cmd ippool add pool-ILV 10.10.11.1-1"
ssh root@$CLIENT_IP "ip netns exec ns2 pon d2"
echo "now both should be connected"
ssh root@$ACCEL_IP "accel-cmd show sessions"
ssh root@$ACCEL_IP "accel-cmd ippool delete pool-ILV 10.10.11.1-1"
ssh root@$ACCEL_IP "accel-cmd ippool delete pool-ILV 10.10.10.1-1"
ssh root@$ACCEL_IP "accel-cmd ippool add pool-ILV $POOL_ILV"
for i in `seq 1 $total_ns`;
do
ssh root@$CLIENT_IP "ip netns exec ns$i poff d$i"
done

echo "************************************************************************************"

echo "Test Case 9"

ssh root@$ACCEL_IP "accel-cmd ippool delete pool-ILV $POOL_ILV"
ssh root@$ACCEL_IP "accel-cmd ippool add pool-ILV 10.10.10.1-1"
ssh root@$CLIENT_IP "ip netns exec ns1 pon d1"
ssh root@$ACCEL_IP "accel-cmd show sessions"
ssh root@$CLIENT_IP "ip netns exec ns1 poff d1"
ssh root@$ACCEL_IP "accel-cmd show sessions"
ssh root@$CLIENT_IP "ip netns exec ns1 pon d1"
ssh root@$ACCEL_IP "accel-cmd show sessions"
for i in `seq 1 $total_ns`;
do
ssh root@$CLIENT_IP "ip netns exec ns$i poff d$i"
done
ssh root@$ACCEL_IP "accel-cmd ippool delete pool-ILV 10.10.10.1-1"
ssh root@$ACCEL_IP "accel-cmd ippool add pool-ILV $POOL_ILV"

echo "************************************************************************************"

echo "Test Case 10"

echo "Not understood"

echo "************************************************************************************"

echo "Test Case 11"

ssh root@$ACCEL_IP "accel-cmd ippool delete pool-ILV $POOL_ILV"
ssh root@$CLIENT_IP "ip netns exec ns1 pon d1"
ssh root@$ACCEL_IP "accel-cmd show sessions"
ssh root@$CLIENT_IP "ip netns exec ns1 poff d1"
ssh root@$ACCEL_IP "accel-cmd ippool add pool-ILV $POOL_ILV"

echo "************************************************************************************"

echo "Test Case 12"

ssh root@$ACCEL_IP "accel-cmd ippool delete pool-ILV $POOL_ILV"
ssh root@$ACCEL_IP "accel-cmd ippool add pool-ILV 10.10.10.1-1"
ssh root@$CLIENT_IP "ip netns exec ns1 pon d1"
ssh root@$CLIENT_IP "ip netns exec ns2 pon d2"
ssh root@$ACCEL_IP "accel-cmd show sessions"
for i in `seq 1 $total_ns`;
do
ssh root@$CLIENT_IP "ip netns exec ns$i poff d$i"
done
ssh root@$ACCEL_IP "accel-cmd ippool delete pool-ILV 10.10.10.1-1"
ssh root@$ACCEL_IP "accel-cmd ippool add pool-ILV $POOL_ILV"

echo "************************************************************************************"

echo "Test Case 13"

for i in `seq 1 $total_ns`;
do
ssh root@$CLIENT_IP "ip netns exec ns$i poff d$i"
done
ssh root@$ACCEL_IP "accel-cmd ippool percentage"

echo "************************************************************************************"

echo "Test Case 14"

ssh root@$ACCEL_IP "accel-cmd ippool delete pool-ILV $POOL_ILV"
ssh root@$ACCEL_IP "accel-cmd ippool add pool-ILV 10.10.10.1-1"
for i in `seq 1 $total_ns`;
do
ssh root@$CLIENT_IP "ip netns exec ns$i pon d$i"
done
ssh root@$ACCEL_IP "accel-cmd ippool percentage"
for i in `seq 1 $total_ns`;
do
ssh root@$CLIENT_IP "ip netns exec ns$i poff d$i"
done
ssh root@$ACCEL_IP "accel-cmd ippool delete pool-ILV 10.10.10.1-1"
ssh root@$ACCEL_IP "accel-cmd ippool add pool-ILV $POOL_ILV"

echo "************************************************************************************"

echo "Test Case 15"

ssh root@$ACCEL_IP "accel-cmd ippool percentage"

echo "************************************************************************************"

echo "Test Case 16"

ssh root@$ACCEL_IP "accel-cmd ippool delete pool-ILV $POOL_ILV"
ssh root@$ACCEL_IP "accel-cmd ippool add pool-ILV 10.10.10.1-2"
ssh root@$CLIENT_IP "ip netns exec ns1 pon d1"
ssh root@$ACCEL_IP "accel-cmd ippool percentage"
ssh root@$CLIENT_IP "ip netns exec ns2 pon d2"
ssh root@$ACCEL_IP "accel-cmd ippool percentage"

echo "************************************************************************************"

echo "Test Case 17"

ssh root@$ACCEL_IP "accel-cmd ippool percentage"
ssh root@$CLIENT_IP "ip netns exec ns1 poff d1"
ssh root@$ACCEL_IP "accel-cmd ippool percentage"
ssh root@$CLIENT_IP "ip netns exec ns2 poff d2"
ssh root@$ACCEL_IP "accel-cmd ippool percentage"
ssh root@$ACCEL_IP "accel-cmd ippool delete pool-ILV 10.10.10.1-1"
ssh root@$ACCEL_IP "accel-cmd ippool add pool-ILV $POOL_ILV"
for i in `seq 1 $total_ns`;
do
ssh root@$CLIENT_IP "ip netns exec ns$i poff d$i"
done

echo "************************************************************************************"

echo "Test Case 18"

ssh root@$ACCEL_IP "accel-cmd ippool add pool-ILV $POOL_ILV"
ssh root@$ACCEL_IP "accel-cmd ippool show"

echo "************************************************************************************"

echo "Test Case 19"

ssh root@$ACCEL_IP "accel-cmd ippool add pool-I $POOL_ILV"
ssh root@$ACCEL_IP "accel-cmd ippool show"
ssh root@$ACCEL_IP "accel-cmd ippool delete pool-I $POOL_ILV"
ssh root@$ACCEL_IP "accel-cmd ippool add pool-ILV $POOL_ILV"
ssh root@$ACCEL_IP "accel-cmd ippool add pool-I $POOL_I"

echo "************************************************************************************"

echo "Test Case 20"

ssh root@$ACCEL_IP "accel-cmd ippool add pool-I $POOL_ILV"
ssh root@$ACCEL_IP "accel-cmd ippool show"
ssh root@$ACCEL_IP "accel-cmd ippool delete pool-I $POOL_ILV"
ssh root@$ACCEL_IP "accel-cmd ippool add pool-ILV $POOL_ILV"
ssh root@$ACCEL_IP "accel-cmd ippool add pool-I $POOL_I"

echo "************************************************************************************"

echo "Test Case 21"

sh root@$ACCEL_IP "accel-cmd ippool add pool-ILV $POOL_ILV"
ssh root@$ACCEL_IP "accel-cmd ippool show"

echo "************************************************************************************"

echo "Test Case 22"

ssh root@$ACCEL_IP "accel-cmd ippool delete pool-ILV $POOL_ILV"
ssh root@$ACCEL_IP "accel-cmd ippool add pool-ILV 10.10.10.1-1"
ssh root@$CLIENT_IP "ip netns exec ns1 pon d1"
ssh root@$ACCEL_IP "accel-cmd ippool percentage"
ssh root@$ACCEL_IP "accel-cmd ippool add pool-ILV 10.10.11.1-1"
ssh root@$ACCEL_IP "accel-cmd ippool percentage"
ssh root@$ACCEL_IP "accel-cmd ippool delete pool-ILV 10.10.10.1-1"
ssh root@$ACCEL_IP "accel-cmd ippool delete pool-ILV 10.10.11.1-1"
ssh root@$ACCEL_IP "accel-cmd ippool add pool-ILV $POOL_ILV"
for i in `seq 1 $total_ns`;
do
ssh root@$CLIENT_IP "ip netns exec ns$i poff d$i"
done

echo "************************************************************************************"

echo "Test Case 23"

sh root@$ACCEL_IP "accel-cmd ippool add pool-U 10.10.10.1-1"
ssh root@$ACCEL_IP "accel-cmd ippool show"
ssh root@$ACCEL_IP "accel-cmd ippool delete pool-U 10.10.10.1-1"
ssh root@$ACCEL_IP "accel-cmd ippool show"




#echo "Test Case 3"
#n_user_I=ssh root@$ACCEL_IP "accel-cmd show sessions match username user-ILV | wc -l"
#if [[ "$n_user_I" > "3"  ]]
#then
#ssh root@172.30.234.66 "accel-cmd ippool delete user-ILV"
#ssh root@172.30.234.66 "accel-cmd ippool add user-ILV 10.10.10.1-1"
#ip netns exec ns1 pon
#ssh root@172.30.234.66 "accel-cmd show sessions"
#ssh root@172.30.234.66 "accel-cmd ippool add user-ILV 10.10.11.1-1"
#ip netns exec ns2 pon
#ssh root@172.30.234.66 "accel-cmd show sessions"
#ip netns exec ns1 poff
#ip netns exec ns2 poff
#
#echo "Test Case 4"
#ssh root@172.30.234.66 "accel-cmd ippool delete user-ILV"
#ssh root@172.30.234.66 "sed -n "66,77p" /etc/accel-ppp.conf"
#ssh root@172.30.234.66 "accel-cmd ippool add user-ILV 10.10.10.1-2"
#ssh root@172.30.234.66 "accel-cmd ippool add user-ILV 10.10.11.1-2"
#ssh root@172.30.234.66 "accel-cmd ippool delete user-ILV 10.10.10.1-2"
#ip netns exec ns1 pon
#ip netns exec ns2 pon
#ssh root@172.30.234.66 "accel-cmd show sessions"
#ip netns exec ns1 poff
#ip netns exec ns2 poff
#
#echo "Test Case 5"
#ssh root@172.30.234.66 "accel-cmd ippool delete user-ILV"
#ssh root@172.30.234.66 "sed -n "66,77p" /etc/accel-ppp.conf"
#ssh root@172.30.234.66 "accel-cmd ippool add user-ILV 10.10.10.1-2"
#ip netns exec ns1 pon
#ip netns exec ns2 pon
#ssh root@172.30.234.66 "accel-cmd ippool add user-ILV 10.10.11.1-2"
#ssh root@172.30.234.66 "accel-cmd ippool delete user-ILV 10.10.10.1-2"
#sleep(20)
#ssh root@172.30.234.66 "accel-cmd show sessions"

else
echo "Please make confirm you have all pool for all users available. Thank you"
fi

