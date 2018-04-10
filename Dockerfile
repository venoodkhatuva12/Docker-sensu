FROM centos:centos7

MAINTAINER Dixit dbura@apple.com

# Basic packages
RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
  && yum -y install passwd sudo git wget openssl openssh openssh-server openssh-clients jq

# Create user
RUN useradd sensu \
 && echo "sensu" | passwd sensu --stdin \
 && sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config \
 && sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config \
 && echo "sensu ALL=(ALL) ALL" >> /etc/sudoers.d/sensu

# Redis
RUN yum install -y redis

# RabbitMQ
RUN yum install -y socat \
  && rpm -Uvh https://dl.bintray.com/rabbitmq/rpm/erlang/20/el/7/x86_64/erlang-20.1.7.1-1.el7.centos.x86_64.rpm \
  && rpm --import http://www.rabbitmq.com/rabbitmq-signing-key-public.asc \
  && rpm -Uvh http://www.rabbitmq.com/releases/rabbitmq-server/current/rabbitmq-server-3.6.15-1.el7.noarch.rpm \
  && git clone git://github.com/joemiller/joemiller.me-intro-to-sensu.git \
  && cd joemiller.me-intro-to-sensu/; ./ssl_certs.sh clean && ./ssl_certs.sh generate \
  && mkdir /etc/rabbitmq/ssl \
  && cp /joemiller.me-intro-to-sensu/server_cert.pem /etc/rabbitmq/ssl/cert.pem \
  && cp /joemiller.me-intro-to-sensu/server_key.pem /etc/rabbitmq/ssl/key.pem \
  && cp /joemiller.me-intro-to-sensu/testca/cacert.pem /etc/rabbitmq/ssl/
ADD ./config-files/rabbitmq.config /etc/rabbitmq/
RUN rabbitmq-plugins enable rabbitmq_management

# Sensu server
ADD ./config-files/sensu.repo /etc/yum.repos.d/
RUN yum install -y sensu
ADD ./config-files/config.json /etc/sensu/
RUN mkdir -p /etc/sensu/ssl \
  && cp /joemiller.me-intro-to-sensu/client_cert.pem /etc/sensu/ssl/cert.pem \
  && cp /joemiller.me-intro-to-sensu/client_key.pem /etc/sensu/ssl/key.pem

# uchiwa
RUN yum install -y uchiwa
ADD ./config-files/uchiwa.json /etc/sensu/

# supervisord
RUN wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py \ 
  && pip install supervisor

ADD ./config-files/supervisord.conf /etc/supervisord.conf

RUN /etc/init.d/sshd start && /etc/init.d/sshd stop

EXPOSE 22 3000 4567 5671 15672

CMD ["/usr/bin/supervisord"]

