FROM ruby:2.2.3

RUN useradd --create-home -s /bin/bash album-manager

ARG CONTAINER_ENGINE_ARG
ARG USE_NGINX_PLUS_ARG
ARG USE_VAULT_ARG
ARG NETWORK_ARG

# CONTAINER_ENGINE specifies the container engine to which the
# containers will be deployed. Valid values are:
# - kubernetes (default)
# - mesos
# - local
ENV USE_NGINX_PLUS=${USE_NGINX_PLUS_ARG:-true} \
    USE_VAULT=${USE_VAULT_ARG:-false} \
    APP="unicorn -c /usr/src/app/unicorn.rb -D" \
    CONTAINER_ENGINE=${CONTAINER_ENGINE_ARG:-kubernetes} \
    NETWORK=${NETWORK_ARG:-fabric}

COPY nginx/ssl /etc/ssl/nginx/

# Fix for jessie repo
RUN printf "deb http://archive.debian.org/debian/ jessie main\ndeb-src http://archive.debian.org/debian/ jessie main\ndeb http://security.debian.org jessie/updates main\ndeb-src http://security.debian.org jessie/updates main" > /etc/apt/sources.list
# Install Required packages for installing NGINX Plus
RUN apt-get update && apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  jq \
  libffi-dev \
  librecode0 \
  libsqlite3-0 \
  libssl-dev \
  libxml2 \
  lsb-release \
  make \
  vim \
  wget \
  unzip \
  --no-install-recommends && \
  rm -r /var/lib/apt/lists/* && \
  mkdir -p /etc/ssl/nginx

ADD install-nginx.sh /usr/local/bin/
COPY nginx /etc/nginx/
COPY ./app /usr/src/app
WORKDIR /usr/src/app

# Install nginx and build the application
RUN /usr/local/bin/install-nginx.sh && \
  mkdir -p /var/log/nginx && \
  ln -sf /dev/stdout /var/log/nginx/access_log && \
  ln -sf /dev/stderr /var/log/nginx/error_log && \
  mkdir /tmp/sockets && \
  gem install bundler && \
  bundle install --force

RUN mkdir -p /var/log/unicorn && \
    touch /var/log/unicorn/unicorn.stdout.log && \
    touch /var/log/unicorn/unicorn.stderr.log && \
    ln -sf /dev/stdout /var/log/unicorn/unicorn.stdout.log && \
    ln -sf /dev/stderr /var/log/unicorn/unicorn.stderr.log

RUN chmod -R 777 /usr/src/app

EXPOSE 80 443 12001

CMD ["/usr/src/app/start.sh"]
