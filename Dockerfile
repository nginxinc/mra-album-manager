FROM ruby:2.2.3

ENV USE_NGINX_PLUS=true \
    USE_VAULT=false \
    APP="unicorn -c /usr/src/app/unicorn.rb -D" \
# CONTAINER_ENGINE specifies the container engine to which the
# containers will be deployed. Valid values are:
# - kubernetes
# - mesos
# - local
    CONTAINER_ENGINE=kubernetes

COPY nginx/ssl /etc/ssl/nginx/
#Install Required packages for installing NGINX Plus
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

# Install nginx
ADD install-nginx.sh /usr/local/bin/
COPY nginx /etc/nginx/
COPY ./status.html /usr/share/nginx/html/status.html
RUN /usr/local/bin/install-nginx.sh && \
# forward request and error logs to docker log collector
    ln -sf /dev/stdout /var/log/nginx/access_log && \
	ln -sf /dev/stderr /var/log/nginx/error_log && \
	mkdir /tmp/sockets && \
# throw errors if Gemfile has been modified since Gemfile.lock
    bundle config --global frozen 1 && \
    mkdir -p /usr/src/app

COPY ./app /usr/src/app
WORKDIR /usr/src/app

RUN bundle install

RUN ln -sf /dev/stdout /usr/src/app/log/unicorn.stdout.log && \
		ln -sf /dev/stderr /usr/src/app/log/unicorn.stderr.log

EXPOSE 80 443 12001

CMD ["./start.sh"]
