FROM debian

ENV MINGW=/mingw

ARG TARGET_BITS=64
ARG PKG_CONFIG_VERSION=0.29.2
ARG GCC_THREAD_MODEL=posix
ARG BINUTILS_VERSION=2.33.1
ARG MINGW_VERSION=7.0.0
ARG GCC_VERSION=9.2.0
ARG GDB_VERSION=8.3.1

COPY install-mingw.sh /
RUN dpkg --add-architecture i386 \
	&& apt-get update \
	&& apt-get -y install bash wine-development wine${TARGET_BITS}-development \
	&& /install-mingw.sh
