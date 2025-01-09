FROM debian:bookworm

WORKDIR /build
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install --no-install-recommends -y \
    unzip  wget bash xorriso ruby ruby-rubygems jq python3 \
    python3-jinja2 isolinux
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

RUN gem install fpm

RUN mkdir -p /build

RUN mkdir -p        /build/bin
RUN mkdir -p        /build/configs
RUN mkdir -p        /build/debian-pkg-post-install/script.d
RUN mkdir -p        /build/lib
RUN mkdir -p        /build/logs


COPY bin/*          /build/bin
COPY configs/*      /build/configs
COPY debian-pkg-post-install/scripts.d/* /build/debian-pkg-post-install/scripts.d/
COPY debian-pkg-post-install/*           /build/debian-pkg-post-install/
COPY lib/*          /build/lib


ENTRYPOINT ["/build/bin/make-srv-iso.sh"]
