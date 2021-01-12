#!/bin/bash

cd ~

TESTNET_PATH=/tmp/latestnet
NODE_COUNT=$(ls $TESTNET_PATH | grep node | wc -l)
WINDOWS_COUNT=$(( $(( $NODE_COUNT + 3 )) / 4 ))
# tmux session name
SN=PRIVLA

tmux kill-session -t $SN

cd $TESTNET_PATH 

# start tmux session
tmux new-session -d -s $SN -n nodes0
# create windows and panes
for (( i=0; i < $WINDOWS_COUNT; ++i))
do
    if [ $i -gt 0 ]
    then 
        tmux new-window -n nodes$i
    fi
    tmux split-window -dv
    tmux split-window -dh      
    tmux select-pane -t 2 
    tmux split-window -dh      
done

# start nodes
current_node=1
for (( i=0; i < $WINDOWS_COUNT; ++i))
do
    tmux select-window -t $i
    for (( j=0; j < 4; ++j))
    do
        tmux select-pane -t $j
        num=$(printf "%02d" $current_node)
        tmux send "cd node_$num && LOG_LEVEL=Info COMPlus_PerfMapEnabled=1 ./Lachain.Console" ENTER
        ((current_node++))
        if [ $current_node -gt $NODE_COUNT ]
        then
            break
        fi
    done
done

# open tmux for this session
tmux a -t $SN
