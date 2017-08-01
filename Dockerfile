FROM ruby:2.2.3

ENV USE_NGINX_PLUS=false \
    VAULT_TOKEN=4b9f8249-538a-d75a-e6d3-69f5355c1751 \
    VAULT_ADDR=http://vault.mra.nginxps.com:8200


COPY vault_env.sh /etc/letsencrypt/
#Install Required packages for installing NGINX Plus
RUN apt-get update && apt-get install -y \
	jq \
	libffi-dev \
	libssl-dev \
	make \
	wget \
	curl \
	vim \
	apt-transport-https \
	ca-certificates \
	curl \
	librecode0 \
	libsqlite3-0 \
	libxml2 \
	lsb-release \
	unzip \
	--no-install-recommends && \
	rm -r /var/lib/apt/lists/* && \
# Install vault client

    wget -q https://releases.hashicorp.com/vault/0.6.0/vault_0.6.0_linux_amd64.zip && \
	  unzip -d /usr/local/bin vault_0.6.0_linux_amd64.zip && \
    . /etc/letsencrypt/vault_env.sh && \
    mkdir -p /etc/ssl/nginx 

# Install nginx
ADD install-nginx.sh /usr/local/bin/
COPY nginx /etc/nginx/
COPY ./status.html /usr/share/nginx/html/status.html
RUN /usr/local/bin/install-nginx.sh && \
# forward request and error logs to docker log collector
    ln -sf /dev/stdout /var/log/nginx/access.log && \
	ln -sf /dev/stderr /var/log/nginx/error.log && \
	mkdir /tmp/sockets && \
# throw errors if Gemfile has been modified since Gemfile.lock
    bundle config --global frozen 1 && \
    mkdir -p /usr/src/app

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock /usr/src/app/
RUN bundle install

COPY . /usr/src/app

RUN ln -sf /dev/stdout /usr/src/app/log/unicorn.stdout.log && \
		ln -sf /dev/stderr /usr/src/app/log/unicorn.stderr.log

EXPOSE 80 443

ENV APP="unicorn -c /usr/src/app/unicorn.rb -D"
CMD ["./start.sh"]
