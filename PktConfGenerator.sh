#!/bin/bash

# pkt_buf="00 00 00 00 00 00 00 00 00 00 00 00 \
#          08 00 45 00 00 1c 00 01 00 00 40 11 \
#          b6 25 02 01 01 02 c0 a8 01 00 13 88 13 88"
pkt_buf="00 00 00 00 00 00 00 00 00 00 00 00 \
         08 00 45 00 00 2a e0 5e 40 00 40 01 \
         8e c0 64 56 01 6c 64 56 01 6a 08 00 \
         b6 08 7a 8b 00 01 00 00 00 00 72 97 \
         06 00 00 00 00 00 10 11"

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

ip_len=$(( pkt_size - 4 - 10 - 4 )) # e.g. 64Byte - 4Byte - 10Byte
ip_len=($(printf "%04x" $ip_len))
ip_len=$(echo ${ip_len:0:2} ${ip_len:2:4})
pkt_buf="00 00 00 00 00 00 00 00 00 00 00 00 \
         08 00 45 00 $ip_len e0 5e 40 00 40 01 \
         8e c0 64 56 01 6c 64 56 01 6a 08 00 \
         b6 08 7a 8b 00 01 00 00 00 00 72 97 \
         06 00 00 00 00 00 10 11"
# Instead of ip_len
# pkt_buf=$(echo ${pkt_buf:0:15})" "$ip_len" "$(echo ${pkt_buf:19:55})

# echo $pkt_buf
for i in `seq $base_size $(( pkt_size - 10 - 4 - 1 - 4 ))`; do
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

sed -i 's/src\ ipv4\=1\./src\ ipv4\=2\./g' $output2
sed -i 's/11:11:11:11:11:11/33:33:33:33:33:33/g' $output2
sed -i 's/22:22:22:22:22:22/44:44:44:44:44:44/g' $output2
sed -i 's/1.0.0.1/1.0.0.2/g' $output2


pcap_out1="1-"$pkt_size"B-"$n_flows"flows.pcap"
pcap_out2="2-"$pkt_size"B-"$n_flows"flows.pcap"
./PcapGenerator -f $output1 -o $pcap_out1
./PcapGenerator -f $output2 -o $pcap_out2