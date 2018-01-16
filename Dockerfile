FROM ruby:2.2.3

ARG CONTAINER_ENGINE_ARG
ARG USE_NGINX_PLUS_ARG
ARG USE_VAULT_ARG

# CONTAINER_ENGINE specifies the container engine to which the
# containers will be deployed. Valid values are:
# - kubernetes (default)
# - mesos
# - local
ENV USE_NGINX_PLUS=${USE_NGINX_PLUS_ARG:-true} \
    USE_VAULT=${USE_VAULT_ARG:-false} \
    APP="unicorn -c /usr/src/app/unicorn.rb -D" \
    CONTAINER_ENGINE=${CONTAINER_ENGINE_ARG:-kubernetes}

COPY nginx/ssl /etc/ssl/nginx/

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
  ln -sf /dev/stdout /var/log/nginx/access_log && \
  ln -sf /dev/stderr /var/log/nginx/error_log && \
  mkdir /tmp/sockets && \
  gem install bundler && \
  bundle install --force

RUN mkdir -p /usr/src/app/log/ && \
    touch /usr/src/app/log/unicorn.stdout.log && \
    touch /usr/src/app/log/unicorn.stderr.log && \
    ln -sf /dev/stdout /usr/src/app/log/unicorn.stdout.log && \
    ln -sf /dev/stderr /usr/src/app/log/unicorn.stderr.log

EXPOSE 80 443 12001

CMD ["/usr/src/app/start.sh"]
