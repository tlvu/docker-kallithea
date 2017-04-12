FROM ubuntu:14.04

MAINTAINER Alexey Nurgaliev <atnurgaliev@gmail.com>

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y python python-pip python-ldap mercurial git \
                       python-dev software-properties-common libmysqlclient-dev libpq-dev \
                       libffi-dev && \
    add-apt-repository -y ppa:nginx/stable && \
    apt-get update && \
    apt-get install -y nginx && \
    \
    mkdir /kallithea && \
    cd /kallithea && \
    mkdir -m 0777 config repos logs && \
    hg clone https://bitbucket.org/domruf/kallithea -u 8052dc3f038e73c969a1909e631620138701c44b && \
    cd kallithea && \
    rm -r .hg && \
    pip install --upgrade pip setuptools && \
    pip install -e . && \
    python setup.py compile_catalog && \
    \
    pip install mysql-python && \
    pip install psycopg2 && \
    pip install hg-evolve && \
    \
    apt-get purge --auto-remove -y python-dev software-properties-common && \
    \
    rm /etc/nginx/sites-enabled/*

ADD kallithea_vhost /etc/nginx/sites-enabled/kallithea_vhost
ADD run.sh /kallithea/run.sh

VOLUME ["/kallithea/config", "/kallithea/repos", "/kallithea/logs"]

EXPOSE 80

CMD ["/kallithea/run.sh"]
