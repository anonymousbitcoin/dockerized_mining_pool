# ANON Mining Pool

This was built on Ubuntu 16 with at least 2 CPU cores (wallet compile uses `-j2` and needs 2 cores).

install docker (copy paste below)

`sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common git && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && sudo apt-get update && sudo apt-get install -y docker-ce`

pull repo

`git clone https://github.com/anonymousbitcoin/dockerized_mining_pool.git`

`cd dockerized_mining_pool`

update your wallet public/private keys in `pool_config.json` lines 5-11 (public). and `entrypoint.sh` lines 7-9 (private).

build container

`sudo docker build -t anon-pool:latest .`

make data directory to mount

`mkdir -p ~/data/anon`

run pool container

first port is HTTP, second is P2P for node, third is stratum (ports are - mapped:interal).

`sudo docker run -p 8080:8080 -p 33130:33130 -p 3030:3030 -d -m="6g" -v ~/data/anon:/root/.anon --name anon-pool anon-pool:latest`

to get into container, if needed

`sudo docker exec -it anon-pool /bin/bash`
