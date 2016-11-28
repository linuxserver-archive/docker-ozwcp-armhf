FROM lsiobase/alpine.armhf
MAINTAINER zaggash

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# build prerequisite packages
RUN \
	# install base pkgs
	apk add --no-cache \
		libmicrohttpd \
		libstdc++ \
		gnutls \
		libusb \
		eudev && \
	
	# install dev pkgs
	apk add --no-cache --virtual=build-dependencies \
		git \
		linux-headers \
		libmicrohttpd-dev \
		libusb-dev \
		eudev-dev \
		gnutls-dev \
		make \
		gcc \
		g++ && \

	# openzwave
	git -C /tmp clone -q https://github.com/OpenZWave/open-zwave.git && \
	cd /tmp/open-zwave && \
	make && \
	cp -R ./config /app/ && \

	# ozwcp
	git -C /tmp clone -q https://github.com/OpenZWave/open-zwave-control-panel.git && \
	cd /tmp/open-zwave-control-panel && \
        sed -i 's/^#GNUTLS/GNUTLS/' Makefile && \
        sed -i 's/^LIBUSB.*//' Makefile && \
        sed -i 's/^LIBS.*//' Makefile && \
        sed -i 's/^#LIBUSB/LIBUSB/' Makefile && \
        sed -i 's/^#LIBS/LIBS/' Makefile && \
	make && \
	cp -t /app/ ozwcp cp.html cp.js openzwavetinyicon.png README && \

	# cleanup
        apk del --purge \
                build-dependencies && \
        rm -rf /var/cache/apk/* /tmp/*

# copy local files
COPY root/ /

# ports and volumes
VOLUME /config
EXPOSE 8888
