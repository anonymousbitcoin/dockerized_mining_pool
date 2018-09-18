FROM ubuntu:xenial

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# OS & system packages
RUN apt-get update
RUN apt-get upgrade
RUN apt-get -y install \
    build-essential pkg-config libc6-dev m4 g++-multilib \
    autoconf libtool ncurses-dev unzip git python \
    zlib1g-dev wget bsdmainutils automake curl \
    libsodium-dev libboost-all-dev libboost-system-dev \
    libboost-filesystem-dev libboost-chrono-dev \
    libboost-program-options-dev libboost-test-dev libboost-thread-dev

RUN git clone https://github.com/anonymousbitcoin/anon.git
  cd anon && \
  ./anonutil/build.sh -j2 && \
  ./anonutil/fetch-params.sh

# DON'T CHANGE ABOVE OR IT WILL TAKE A LONG TIME TO COMPILE

# nodejs install
ENV NVM_DIR /usr/local/nvm
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh | bash
ENV NODE_VERSION 8.11.3
RUN /bin/bash -c "source $NVM_DIR/nvm.sh && nvm install $NODE_VERSION && nvm use $NODE_VERSION"

ENV NODE_PATH $NVM_DIR/versions/node/$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/$NODE_VERSION/bin:$PATH

RUN ln -sf /usr/local/nvm/versions/node/v$NODE_VERSION/bin/node /usr/bin/nodejs
RUN ln -sf /usr/local/nvm/versions/node/v$NODE_VERSION/bin/node /usr/bin/node
RUN ln -sf /usr/local/nvm/versions/node/v$NODE_VERSION/bin/npm /usr/bin/npm

# Redis - download and compile
RUN wget http://download.redis.io/redis-stable.tar.gz && \
  tar xvzf redis-stable.tar.gz && \
  cd redis-stable && \
  make
# Redis - copy binaries to directory in path
RUN cp /redis-stable/src/redis-server /usr/local/bin/
RUN cp /redis-stable/src/redis-cli /usr/local/bin/
# Redis - configure server
RUN mkdir /etc/redis && mkdir /var/redis && mkdir /var/redis/6379
RUN cp /redis-stable/utils/redis_init_script /etc/init.d/redis_6379
COPY redis.conf ./etc/redis/6379.conf
RUN update-rc.d redis_6379 defaults

#wallet daemon config
COPY wallet_config_anon.conf ./root/.anon/anon.conf

RUN git clone https://github.com/s-nomp/s-nomp.git nomp && \
  cd nomp && \
  npm update && \
  npm install

WORKDIR /nomp

# Pool configs
COPY nomp_config.json ./config.json
COPY coin_config_anon.json ./coins/anon.json
COPY pool_config.json ./pool_configs/anon.json

RUN npm install -g pm2

#Entrypoint
COPY entrypoint.sh ./entrypoint.sh
RUN chmod +x entrypoint.sh

EXPOSE 8080 33130 3030

ENTRYPOINT ["./entrypoint.sh"]
