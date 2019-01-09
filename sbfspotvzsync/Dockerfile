# FROM debian:stretch-slim

# RUN apt-get update && apt-get install -y  \
#   libcurl4-openssl-dev \
#   default-libmysqlclient-dev \
#   build-essential \
#   libbluetooth-dev \
#   libboost-date-time-dev
  
# RUN mkdir -p /var/log/sbfspot
  
# COPY src/ /tmp/
# RUN make -C /tmp/SBFspotUploadDaemon install_mysql clean_release_mysql
# ENTRYPOINT /usr/local/bin/sbfspot.3/SBFspotUploadDaemon && tail -f /var/log/sbfspot/*

FROM python:3

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir mysql-connector
RUN pip install --no-cache-dir requests

COPY . .

CMD [ "python", "./run_all.py" ]