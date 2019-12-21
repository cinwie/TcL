#!/bin/sh
# Cin Wie
# http://github.com/cinwie/
# 2019
#  ./ipv6.sh <network_v6> <max count>
MAXCOUNT=$2
count=0
network_v6=$1 # your ipv6 network prefix
rnd_ipv6_block () {
HEX="tr -dc "[:xdigit:]" < /dev/urandom | head -c 16 | sed 's/..../:&/g'"
ipv6=$network_v6$(eval $HEX);
}
echo "$MAXCOUNT ......... IPv6:"
echo "-----------------"
while [ $count -lt $MAXCOUNT ]
do
count=`expr $count + 1`
rnd_ipv6_block
echo $ipv6
#echo "/sbin/ifconfig \$1 inet6 add $ipv6/64" >> add.ipv6
#echo "/sbin/ifconfig \$1 inet6 del $ipv6/64" >> del.ipv6
echo "up ip -6 addr add $ipv6/128 dev ens3:0" >> add.ipv6
echo "down ip -6 addr del $ipv6/128 dev ens3:0" >> del.ipv6
done

