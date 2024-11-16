# Default release is 20.04
ARG BASE_IMAGE_RELEASE=20.04
# Default base image 
ARG BASE_IMAGE=ubuntu
# BRANCH
ARG BRANCH=dev

FROM abcdesktopio/ntlm_auth:$BASE_IMAGE_RELEASE as ntlm_auth

# --- BEGIN builder ---
FROM $BASE_IMAGE:$BASE_IMAGE_RELEASE as builder
ARG BRANCH
ENV DEBIAN_FRONTEND=noninteractive
ENV BRANCH=${BRANCH}
RUN echo current branch is ${BRANCH}

# install git for versionning
# get version.json file using mkversion.sh bash script
RUN  apt-get update && apt-get install -y --no-install-recommends \
	git \
	ca-certificates 				

RUN cd /var && git clone -b ${BRANCH} https://github.com/abcdesktopio/pyos.git 
RUN cd /var/pyos && ./mkversion.sh && cat version.json
RUN curl --output /var/pyos/od.config  "https://raw.githubusercontent.com/abcdesktopio/conf/refs/heads/main/reference/od.config.${BRANCH}"
# End of builder

# Start here
FROM $BASE_IMAGE:$BASE_IMAGE_RELEASE
ENV DEBIAN_FRONTEND noninteractive
# libglib2 	is used by ntlm_auth
# samba-common 	is used for nbmlookup
# krb5-user 	is used for kinit
RUN apt-get update && apt-get install -y --no-install-recommends  \
	python3 		\
 	python3-crypto		\ 
	python3-pip		\ 
	python3-six		\
        python3-requests 	\
	python3-urllib3		\
        python3-httplib2 	\
	python3-geoip		\		
	python3-geoip2		\
	python3-pymongo 	\
 	python3-memcache        \
	python3-distutils	\
	python3-kerberos	\
	python3-setuptools	\
	python3-gssapi		\
	python3-jwt		\
	libglib2.0-0		\
	samba-common-bin	\
    && apt-get clean            \
    && rm -rf /var/lib/apt/lists/*

# update ldconfig
RUN echo "/usr/lib/x86_64-linux-gnu/samba" >> /etc/ld.so.conf.d/x86_64-linux-gnu.conf
RUN /usr/sbin/ldconfig

RUN apt-get update && apt-get install -y --no-install-recommends  \
	curl				\
    	apt-transport-https 		\
    	ca-certificates 		\
    	gnupg-agent 			\
    	software-properties-common	\
    && apt-get clean            	\
    && rm -rf /var/lib/apt/lists/*

# ADD debug tools like telnet netcat dnsutils...
RUN apt-get update && apt-get install -y --no-install-recommends  \
    	telnet	  		\
    	wget			\
    	netcat			\
    	iputils-ping		\
    	dnsutils		\
	net-tools 		\
	vim			\
    && apt-get clean            \
    && rm -rf /var/lib/apt/lists/*

# GeoLite2
RUN mkdir -p /usr/share/geolite2 && \
    wget https://git.io/GeoLite2-ASN.mmdb -P /usr/share/geolite2 && \
    wget https://git.io/GeoLite2-City.mmdb -P /usr/share/geolite2

# need libssl-dev,rustc for rsa>=4.1
RUN apt-get update && apt-get install -y --no-install-recommends  \
	libffi-dev		\
	python3-dev 		\
	libldap2-dev 		\
	libsasl2-dev 		\
	libssl-dev		\
	rustc			\
    && apt-get clean            \
    && rm -rf /var/lib/apt/lists/*

# libnss-ldap
RUN  apt-get update && apt-get install -y \
	cntlm 			\
	sasl2-bin 		\
	libsasl2-2 		\
	libsasl2-modules 	\
	libsasl2-modules-gssapi-mit	\
        krb5-user               \
 	libnss3-tools           \
        ldap-utils              \
	libgssglue1		\
	libgssrpc4		\
	libgss3			\
        libgssapi-krb5-2        \
        libgssglue1		\
	libnss3-tools	 	\
	gss-ntlmssp		\
    && apt-get clean            \
    && rm -rf /var/lib/apt/lists/*


# copy source python code of pyos
COPY --from=builder var/pyos /var/pyos

# copy new ntlm_auth
COPY --from=ntlm_auth  /samba/samba-4.15.13+dfsg/bin/default/source3/utils/ntlm_auth   /var/pyos/oc/auth/ntlm/ntlm_auth 

# install python dep requirements
RUN cd /var/pyos && \
    cat requirements.txt && \
    pip3 install -r requirements.txt --upgrade 

# pem files will be overwrite by kubernetes volumes  
# keep it only for self tests
COPY 	config.payload/ /config.payload
COPY 	config.signing/ /config.signing
COPY    config.usersigning/ /config.usersigning

RUN mkdir -p /var/pyos/logs /config
COPY 	composer /composer
WORKDIR /var/pyos
CMD     ["/var/pyos/od.py"]
EXPOSE 8000
