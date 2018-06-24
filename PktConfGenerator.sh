#!/bin/bash

pkt_buf="00 00 00 00 00 00 00 00 00 00 00 00 \
         08 00 45 00 00 1c 00 01 00 00 40 11 \
         b6 25 02 01 01 02 c0 a8 01 00 13 88 13 88"

udp_len_checksum=" 00 88 14 23"

base_size=42

if [ "$#" -ne 2 ]
then
  echo "Usage: $0 packet_size number_of_flows"
  echo "For example, generate   64 Bytes   100 Flows Configuration: $0 64 100"
  echo "For example, generate 1280 Bytes 10000 Flows Configuration: $0 1280 10000"
  echo "Currently Support Max 100K Flows."
  exit 1
fi

# echo $pkt_buf

pkt_size=$1
n_flows=$2

output1="1-"$pkt_size"B-"$n_flows"flows.cfg"
output2="2-"$pkt_size"B-"$n_flows"flows.cfg"

rm $output1
rm $output2

# TO DO : Fixed UDP Payload Error
pkt_buf=$pkt_buf$udp_len_checksum
echo $base_size
echo  $pkt_size
for i in `seq $base_size $(( pkt_size - 4 - 1))`; do
	pkt_buf=$pkt_buf" 00"
done


# Based IP
A=1
B=1
C=1
D=1

max=254
# eval printf -v ip_pool "%s\ " {$A..$max}.{$B..$max}.{$C..$max}.{$D..$max}
eval printf -v ip_pool "%s\ " 1.{$B..2}.{$C..$max}.{$D..$max}
count=0

for src_ip in $ip_pool; do
	if [ "$count" -ge "$n_flows" ]; then
		break
	fi
	echo "[packet $i]" >> $output1
	echo "pkt buf="$pkt_buf >> $output1
	echo "src mac=11:11:11:11:11:11" >> $output1
	echo "src ipv4="$src_ip >> $output1
	echo "dst mac=22:22:22:22:22:22" >> $output1
	echo "dst ipv4=1.0.0.1" >> $output1
	echo "rep=1" >> $output1
	((count++))
done

cp $output1 $output2

sed -i 's/22:22:22:22:22:22/33:33:33:33:33:33/g' $output2
sed -i 's/1.0.0.1/1.0.0.2/g' $output2

