#!/bin/bash

# start wallet
/anon/src/anond -daemon
sleep 15
# import private key to wallet
/anon/src/anon-cli -rpcuser=User23452asdfhggf4 -rpcpass=Pass90823883479sd importprivkey "private key for t address 1" "" false
/anon/src/anon-cli -rpcuser=User23452asdfhggf4 -rpcpass=Pass90823883479sd z_importkey "private key for z address"
/anon/src/anon-cli -rpcuser=User23452asdfhggf4 -rpcpass=Pass90823883479sd importprivkey "private key for t address 2" "" false
# start redis
/etc/init.d/redis_6379 start
sleep 15
# start mining pool
pm2 start node -- init.js

#to keep the container running
tail -f /dev/null

# start block explorer api
# ./node_modules/bitcore-node-btcp/bin/bitcore-node start
