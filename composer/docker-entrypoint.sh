#!/bin/bash

#########
# if the directory /config exists
# copy all files in /config to /var/pyos directory
# this override all default config files
if [ -d "/config" ]; then
   if [ -f "/config/od.config" ]; then
	cp /config/od.config /var/pyos/od.config
   fi
fi


# check if the the container is running inside a KUBERNETES
# by testing the env $KUBERNETES_SERVICE_HOST
if [ -z "$KUBERNETES_SERVICE_HOST" ]
then
        echo 'Kubernetes is not detected' 
        echo 'Using default config file'
else
	echo 'Kubernetes is detected' 
	mkdir -p ~/.kube
	if [ -f "/config/config" ]; then
          cp /config/config ~/.kube
        fi
fi

# check if config.signing exist
if [ ! -d "/config.signing" ]; then
  echo 'SECURITY WARNING !'
  echo 'No signing key has been defined' 
  echo 'using default signing keys'
  mv /config.signing.default /config.signing
else
  ls -la /config.signing
fi

if [ ! -d "/config.payload" ]; then
  echo 'SECURITY WARNING !'
  echo 'No payload key has been defined' 
  echo 'using default payload keys'
  mv /config.payload.default /config.payload
else
  ls -la /config.signing
fi

echo "starting od.py"
cd /var/pyos
./od.py 
