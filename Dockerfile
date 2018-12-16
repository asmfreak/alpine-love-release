FROM alpine:edge
LABEL maintainer="Pavel Pletenev <cpp.create@gmail.com>"

ENV LUA_VERSION 5.1.5
ENV LUAROCKS_VERSION 3.0.4
ENV BUTLER_VERSION 15.2.1
ENV LOVE_VERSION 11.2
ENV LOVE_RELEASE_VERSION 2.0.9-1

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
  openssl curl

# reference https://github.com/sgerrand/alpine-pkg-glibc
# for a sane glibc version for love and butler
RUN \
  apk --no-cache add ca-certificates wget && \
  wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
  wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-2.28-r0.apk && \
  apk add glibc-2.28-r0.apk && rm -rf glibc-2.28-r0.apk


RUN \
  luarocks install lua-libzip && \
  luarocks install love-release $LOVE_RELEASE_VERSION && \
  luarocks install loverocks && \
  # Install busted
  luarocks install busted

RUN \
  # Install itch.io butler
  mkdir butler-wd && cd butler-wd && \
  curl -L -o butler.zip https://broth.itch.ovh/butler/linux-amd64/${BUTLER_VERSION}/archive/default && \
  unzip butler.zip && rm butler.zip && \ 
  cp -v * /bin/ && \
  chmod 755 /bin/butler && \
  cd / && rm -rf butler-wd && \
  butler -V && \
  butler upgrade

RUN apk add fakeroot dpkg

RUN \
    cd / && \
    wget https://bitbucket.org/rude/love/downloads/love-${LOVE_VERSION}-x86_64.tar.gz && \
    tar xzvf love-${LOVE_VERSION}-x86_64.tar.gz && mv dest love && \
    printf '#!/bin/sh\n/love/love "$@"\n' > /bin/love && chmod +x /bin/love # && \
    love --version && \
    rm -rf love-${LOVE_VERSION}-x86_64.tar.gz
