ARG BASE_DISTRO=SPECIFY_ME

FROM $BASE_DISTRO

ARG USER_UID=SPECIFY_ME
ARG PBI_VERSION=SPECIFY_ME
ARG GIT_VERSION=SPECIFY_ME

USER root

# In case of Proxy based environment, leave the following enabled.
# in Direct internet cases, comment out the following two lines.
#--- PROXY SETUP START
#COPY proxy-configuration/ /
#RUN  export DEBIAN_FRONTEND=noninteractive;apt-get update;apt-get install -y apt-transport-https socket corkscrew apt-utils
#--- END START


# Git Dependencies
RUN  export DEBIAN_FRONTEND=noninteractive;apt-get update;\
			    apt-get install -y build-essential wget gcc \
			    dh-autoreconf libcurl4-gnutls-dev libexpat1-dev \
			    gettext libz-dev libssl-dev
# public-inbox build Dependencies
RUN  export DEBIAN_FRONTEND=noninteractive;\
			    apt-get install -y liburi-perl libemail-mime-perl \
			    libplack-perl libtimedate-perl libdbd-sqlite3-perl \
			    libsearch-xapian-perl libnet-server-perl \
			    libinline-c-perl libemail-address-xs-perl \
			    libplack-middleware-reverseproxy-perl libhighlight-perl \
			    xapian-tools libencode-perl libdbi-perl libperl5.32 \
			    liblinux-inotify2-perl perl-modules libio-compress-perl \
			    libsocket6-perl libcrypt-cbc-perl libplack-test-agent-perl \
			    perl-modules-5.32 libxml-treepp-perl spamassassin man-db

COPY other-configs/ /
COPY other-configs/ /opt/other-configs
COPY build-git.sh /tmp
RUN  GIT_VERSION=$GIT_VERSION /tmp/build-git.sh

COPY build-public-inbox.sh /tmp
RUN  PBI_VERSION=$PBI_VERSION /tmp/build-public-inbox.sh

RUN cp -rvfa /usr/local /opt/local

FROM $BASE_DISTRO

ARG USER_UID=SPECIFY_ME

USER root

#--- PROXY SETUP START
#COPY proxy-configuration/ /
#RUN  export DEBIAN_FRONTEND=noninteractive;apt-get update;apt-get install -y apt-transport-https socket corkscrew apt-utils
#--- END START

# Add an ordinary user - This is not going to change
RUN mkdir -p /workdir && groupadd -r swuser -g $USER_UID && \
useradd -u $USER_UID -r -g swuser -d /workdir -s /sbin/nologin -c "Docker kernel patch user" swuser && \
chown -R swuser:swuser /workdir && mkdir /ccache && chown -R swuser:swuser /ccache

# Git Dependencies
RUN  export DEBIAN_FRONTEND=noninteractive;apt-get update;\
			    apt-get install -y build-essential wget gcc \
			    dh-autoreconf libcurl4-gnutls-dev libexpat1-dev \
			    gettext libz-dev libssl-dev \
			    liburi-perl libemail-mime-perl \
			    libplack-perl libtimedate-perl libdbd-sqlite3-perl \
			    libsearch-xapian-perl libnet-server-perl \
			    libinline-c-perl libemail-address-xs-perl \
			    libplack-middleware-reverseproxy-perl libhighlight-perl \
			    xapian-tools libencode-perl libdbi-perl libperl5.32 \
			    liblinux-inotify2-perl perl-modules libio-compress-perl \
			    libsocket6-perl libcrypt-cbc-perl libplack-test-agent-perl \
			    perl-modules-5.32 libxml-treepp-perl spamassassin man-db\
			    && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

COPY --from=0 /opt /opt

RUN cp -rvfa /opt/other-configs/* / && rm -rvf /opt/other-configs/ && \
    cp -rvfa /opt/local/* /usr/local/ && rm -rf /opt/local && \
    ldconfig /usr/local/lib

USER swuser
WORKDIR /workdir
