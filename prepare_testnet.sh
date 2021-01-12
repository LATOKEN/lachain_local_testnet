# Config places
set -e
TESTNET_PATH=/tmp/latestnet
#SRC_PATH=~/Projects/latoken/lachain/blockchain
SRC_PATH=~/workspace/lachain/blockchain
NODE_BIN_PATH=$SRC_PATH/src/Lachain.Console/bin/Debug/netcoreapp3.1/linux-x64/publish/Lachain.Console
FAULTY=2
NODE_COUNT=10
BLOCK_TARGET=0

# remove old installation
rm -rf $TESTNET_PATH
# create testnet directory
mkdir -p $TESTNET_PATH

for (( i=1; i <= $NODE_COUNT; ++i ))
do
 num=$(printf "%02d" $i)
 mkdir -p $TESTNET_PATH/node_$num/ChainLachain
done

# generate configs in testnet directory
cp -fv $NODE_BIN_PATH  $TESTNET_PATH/Lachain.Console
cd $TESTNET_PATH

IPS=`yes "127.0.0.1" | head -n $NODE_COUNT | tr '\n' ' '`
echo "./Lachain.Console keygen --n $NODE_COUNT --faulty $FAULTY --ips $IPS"
./Lachain.Console keygen --n $NODE_COUNT --faulty $FAULTY --ips $IPS >> keys.txt

for (( i=1; i <= $NODE_COUNT; ++i ))
do
 num=$(printf "%02d" $i)
 NODE_PORT=$((50000+i))
 RPC_PORT=$((7070+i))
 cmd="cat $TESTNET_PATH/config$num.json | jq '.network.port = \$v' --arg v \"$NODE_PORT\" | jq '.rpc.port = \$p' --arg p \"$RPC_PORT\" | jq '.blockchain.targetBlockTime = $BLOCK_TARGET'"

 for (( j=0; j < $NODE_COUNT; ++j ))
 do
  port=$((50000+j+1))
  cmd+=" | jq '.network.peers["
  cmd+=$j
  cmd+="] |= rtrimstr(\"5050\") + \""
  cmd+=$port
  cmd+="\"'"
 done
 cmd+=" >> $TESTNET_PATH/node_"
 cmd+=$num
 cmd+="/config.json"
# echo $cmd
 eval $cmd
 rm -rf $TESTNET_PATH/config$num.json
 mv $TESTNET_PATH/wallet$num.json $TESTNET_PATH/node_$num/wallet.json
 mkdir -p $TESTNET_PATH/node_$num/ChainLachain
 mv $TESTNET_PATH/prv_h$i.txt $TESTNET_PATH/node_$num/ChainLachain/prv_h1.txt
 cp $TESTNET_PATH/Lachain.Console $TESTNET_PATH/node_$num/Lachain.Console
done

rm -rf $TESTNET_PATH/logs
rm -rf $TESTNET_PATH/Lachain.Console
