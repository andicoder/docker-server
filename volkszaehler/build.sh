#!/bin/bash
TARGET=/to_host

# builder image
docker build -t build ./build 

# prepare sources 
docker run -v $(pwd)/dist:$TARGET -t build git clone https://github.com/volkszaehler/volkszaehler.org $TARGET
docker run -v $(pwd)/dist:$TARGET -t build php composer.phar install -d $TARGET --optimize-autoloader --no-dev -vvv

# runtime image
if [ -z $1 ] || [ "$1" != "build" ] ; then
	docker build -t ***REMOVED***/volkszaehler -f Dockerfile.amd64 .
fi
