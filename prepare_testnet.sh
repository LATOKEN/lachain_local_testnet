# Config places
set -e
TESTNET_PATH=/hdd/latestnet
#SRC_PATH=~/Projects/latoken/lachain/blockchain
SRC_PATH=~/src/lachain
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
 num=$(printf "%02d" $i)
 mkdir -p $TESTNET_PATH/node_$num/ChainLachain
done

# generate configs in testnet directory
cp -fv $NODE_BIN_PATH  $TESTNET_PATH/Lachain.Console
cd $TESTNET_PATH

./Lachain.Console keygen --n $NODE_COUNT --faulty $FAULTY --p 7070 --t $BLOCK_TARGET #>> keys.txt

for (( i=1; i <= $NODE_COUNT; ++i ))
do
 num=$(printf "%02d" $i)
 NODE_PORT=$((50000+i))
 RPC_PORT=$((7070+i))
 cmd="cat $TESTNET_PATH/config$num.json"
 cmd+=" >> $TESTNET_PATH/node_"
 cmd+=$num
 cmd+="/config.json"
 echo $cmd
 eval $cmd
 rm -rf $TESTNET_PATH/config$num.json
 mv $TESTNET_PATH/wallet$num.json $TESTNET_PATH/node_$num/wallet.json
 cp $TESTNET_PATH/Lachain.Console $TESTNET_PATH/node_$num/Lachain.Console
done

rm -rf $TESTNET_PATH/logs
rm -rf $TESTNET_PATH/Lachain.Console
