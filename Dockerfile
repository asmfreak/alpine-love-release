FROM alpine:latest
LABEL maintainer="Pavel Pletenev <cpp.create@gmail.com>"

ENV LUA_VERSION 5.1.5
ENV LUAROCKS_VERSION 3.0.4
ENV BUTLER_VERSION 15.2.1

RUN apk add --update --no-cache \
  readline-dev libc-dev \
  make gcc \
  wget git \
  zip unzip \
  ncurses ncurses-dev

RUN \
  wget https://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz -O - | tar -xzf - &&\
  cd lua-$LUA_VERSION && \
  make -j"$(nproc)" linux && \
  make install && \
  cd / && \
  rm -rf lua-${LUA_VERSION}

RUN \
  wget https://luarocks.github.io/luarocks/releases/luarocks-${LUAROCKS_VERSION}.tar.gz -O - \
  | tar -xzf - && \
  cd luarocks-$LUAROCKS_VERSION && \
  ./configure && \
  make -j"$(nproc)" && \
  make install && \
  cd / && \
  rm -rf luarocks-$LUAROCKS_VERSION

RUN apk add --update --no-cache \
  libzip libzip-dev \
  openssl curl libc6-compat

RUN \
  luarocks install lua-libzip && \
  luarocks install love-release && \
  luarocks install loverocks && \
  # Install busted
  luarocks install busted

RUN \
  # Install itch.io butler
  mkdir butler-wd && cd butler-wd && \
  curl -L -o butler.zip https://broth.itch.ovh/butler/linux-amd64/${BUTLER_VERSION}/archive/default && \
  unzip butler.zip && rm butler.zip && \ 
  cp -v * /bin/ && \
  chmod 755 /bin/butler && ldd /bin/butler && objdump -p /bin/7z.so && objdump -p libc7zip.so &&  \
  cd / && rm -rf butler-wd && \
  butler -V && \
  butler upgrade

RUN apk add fakeroot dpkg
