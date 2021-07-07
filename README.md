## Prerequisite

Build binary
```
dotnet publish -p:Configuration=Debug -p:PublishTrimmed=true -p:SelfContained=true -p:PublishSingleFile=true --runtime linux-x64 src/Lachain.Console/Lachain.Console.csproj
```

## Step 1: Prepare testnet

Execute the following commands to create the wallets without password.

```bash
./prepare_testnet.sh
```
You can edit params in this file to match your environment

## Step 2: Start network

```bash
./start_testnet_tmux.sh
```


