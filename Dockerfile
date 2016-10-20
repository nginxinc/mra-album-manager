FROM ruby:2.2.3

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
	--no-install-recommends && rm -r /var/lib/apt/lists/*

# Install vault client
RUN wget -q https://releases.hashicorp.com/vault/0.6.0/vault_0.6.0_linux_amd64.zip && \
	  unzip -d /usr/local/bin vault_0.6.0_linux_amd64.zip

# Download certificate and key from the the vault and copy to the build context
ENV VAULT_TOKEN=4b9f8249-538a-d75a-e6d3-69f5355c1751 \
    VAULT_ADDR=http://vault.ngra.ps.nginxlab.com:8200

RUN mkdir -p /etc/ssl/nginx && \
	  vault token-renew && \
	  vault read -field=value secret/nginx-repo.crt > /etc/ssl/nginx/nginx-repo.crt && \
	  vault read -field=value secret/nginx-repo.key > /etc/ssl/nginx/nginx-repo.key && \
    vault read -field=value secret/ssl/csr.pem > /etc/ssl/nginx/csr.pem && \
    vault read -field=value secret/ssl/certificate.pem > /etc/ssl/nginx/certificate.pem && \
    vault read -field=value secret/ssl/key.pem > /etc/ssl/nginx/key.pem && \
    vault read -field=value secret/ssl/dhparam.pem > /etc/ssl/nginx/dhparam.pem


RUN wget -q -O /etc/ssl/nginx/CA.crt https://cs.nginx.com/static/files/CA.crt && \
	wget -q -O - http://nginx.org/keys/nginx_signing.key | apt-key add - && \
	wget -q -O /etc/apt/apt.conf.d/90nginx https://cs.nginx.com/static/files/90nginx && \
	printf "deb https://plus-pkgs.nginx.com/debian `lsb_release -cs` nginx-plus\n" >/etc/apt/sources.list.d/nginx-plus.list

#Install NGINX Plus
RUN apt-get update && apt-get install -y nginx-plus-extras

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
	ln -sf /dev/stderr /var/log/nginx/error.log

COPY nginx /etc/nginx/

RUN mkdir /tmp/sockets

# Install Amplify
RUN curl -sS -L -O  https://github.com/nginxinc/nginx-amplify-agent/raw/master/packages/install.sh && \
	API_KEY='0202c79a3d8411fcf82b35bc3d458f7e' AMPLIFY_HOSTNAME='mesos-album-manager' sh ./install.sh

COPY ./status.html /usr/share/nginx/html/status.html

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install

COPY . /usr/src/app

RUN ln -sf /dev/stdout /usr/src/app/log/unicorn.stdout.log && \
		ln -sf /dev/stderr /usr/src/app/log/unicorn.stderr.log

# Install and run NGINX config generator
RUN wget -q https://s3-us-west-1.amazonaws.com/fabric-model/config-generator/generate_config
RUN chmod +x generate_config && \
    ./generate_config -p /etc/nginx/fabric_config.yaml > /etc/nginx/nginx-fabric.conf

EXPOSE 80 443

ENV APP="unicorn -c /usr/src/app/unicorn.rb -D"
CMD ["./start.sh"]
