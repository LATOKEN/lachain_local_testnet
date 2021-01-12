# Config places
TESTNET_PATH=/tmp/latestnet
SRC_PATH=~/Projects/latoken/lachain/blockchain
NODE_BIN_PATH=$SRC_PATH/src/Lachain.Console/bin/Debug/netcoreapp3.1/linux-x64/publish/Lachain.Console
FAULTY=1
NODE_COUNT=4
BLOCK_TARGET=0

# remove old installation
rm -rf $TESTNET_PATH
# create testnet directory
mkdir -p $TESTNET_PATH

for (( i=1; i <= $NODE_COUNT; ++i ))
do
 mkdir -p $TESTNET_PATH/node_$i/ChainLachain
 cp $SRC_PATH/src/Lachain.Console/prv_h$i.txt $TESTNET_PATH/node_$i/ChainLachain/prv_h1.txt
done

# generate configs in testnet directory
cp -fv $NODE_BIN_PATH  $TESTNET_PATH/Lachain.Console
cd $TESTNET_PATH

./Lachain.Console keygen --n $NODE_COUNT --faulty $FAULTY >> keys.txt

for (( i=1; i <= $NODE_COUNT; ++i ))
do
 NODE_PORT=$((50000+i))
 RPC_PORT=$((7070+i))
 cmd="cat $TESTNET_PATH/config0$i.json | jq '.network.port = \$v' --arg v \"$NODE_PORT\" | jq '.rpc.port = \$p' --arg p \"$RPC_PORT\" | jq '.blockchain.targetBlockTime = $BLOCK_TARGET'"

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
 cmd+=$i
 cmd+="/config.json"
# echo $cmd
 eval $cmd
 rm -rf $TESTNET_PATH/config0$i.json
 mv $TESTNET_PATH/wallet0$i.json $TESTNET_PATH/node_$i/wallet.json
 cp $TESTNET_PATH/Lachain.Console $TESTNET_PATH/node_$i/Lachain.Console
done

rm -rf $TESTNET_PATH/logs
rm -rf $TESTNET_PATH/Lachain.Console
