
# Default release is 20.04
ARG BASE_IMAGE_RELEASE=20.04
# Default base image 
ARG BASE_IMAGE=ubuntu


FROM abcdesktopio/ntlm_auth:$BASE_IMAGE_RELEASE as ntlm_auth

# --- BEGIN builder ---
FROM $BASE_IMAGE:$BASE_IMAGE_RELEASE as builder
ENV DEBIAN_FRONTEND noninteractive

# copy source python code of pyos
COPY    .git /.git
COPY    var/pyos /var/pyos
COPY    var/pyos/.git /var/pyos/.git


# install git for versionning
# get version.json file using mkversion.sh bash script
RUN  apt-get update && apt-get install -y --no-install-recommends \
	git 				\
	&& cd var/pyos 			\
	&& ./mkversion.sh		\
	&& cat version.json
	
# End of builder

# Start here
FROM $BASE_IMAGE:$BASE_IMAGE_RELEASE
ENV DEBIAN_FRONTEND noninteractive
# libglib2 	is used by ntlm_auth
# samba-common 	is used for nbmlookup
# krb5-user 	is used for kinit
RUN apt-get update && apt-get install -y --no-install-recommends  \
	python3 		\
	python3-pip		\ 
	python3-six		\
        python3-requests 	\
	python3-urllib3		\
        python3-httplib2 	\
	python3-geoip		\
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

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# ADD debug for docker cli
# ADD debug telnet client
RUN apt-get update && apt-get install -y --no-install-recommends  \
    	docker-ce-cli 		\
    	telnet	  		\
    	wget			\
    	netcat			\
    	iputils-ping		\
    	dnsutils		\
	net-tools 		\
	vim			\
    && apt-get clean            \
    && rm -rf /var/lib/apt/lists/*


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



# upgrade pip 
RUN     pip3 install --upgrade pip

# copy source python code of pyos
COPY    var/pyos /var/pyos


# copy new ntlm_auth
COPY --from=ntlm_auth  /samba/samba-4.15.13+dfsg/bin/default/source3/utils/ntlm_auth   /var/pyos/oc/auth/ntlm/ntlm_auth 


# copy version json from builder
COPY --from=builder /var/pyos/version.json  /var/pyos/version.json

# install python dep requirements
RUN cd var/pyos && pip3 install -r requirements.txt --upgrade 

RUN 	cp /var/pyos/od.config.reference /var/pyos/od.config
COPY 	config.payload.default/ /config.payload.default
COPY 	config.signing.default/ /config.signing.default
# COPY    config.usersigning.default/ /config.usersigning.default

RUN mkdir -p /var/pyos/logs /config
COPY 	composer /composer
WORKDIR /var/pyos
CMD     ["/composer/docker-entrypoint.sh"]
EXPOSE 8000
