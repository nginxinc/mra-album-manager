FROM ruby:2.2.3

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install

COPY . /usr/src/app

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
	--no-install-recommends && rm -r /var/lib/apt/lists/*

# Download certificate and key from the the vault and copy to the build context
ARG VAULT_TOKEN
RUN mkdir -p /etc/ssl/nginx
RUN wget -q -O - --header="X-Vault-Token: $VAULT_TOKEN" http://vault.ngra.ps.nginxlab.com:8200/v1/secret/nginx-repo.crt | jq -r .data.value > /etc/ssl/nginx/nginx-repo.crt
RUN wget -q -O - --header="X-Vault-Token: $VAULT_TOKEN" http://vault.ngra.ps.nginxlab.com:8200/v1/secret/nginx-repo.key | jq -r .data.value > /etc/ssl/nginx/nginx-repo.key

# Get other files required for installation
COPY ./certificate.pem /etc/ssl/nginx/
COPY ./key.pem /etc/ssl/nginx/
COPY ./dhparam.pem /etc/ssl/nginx/
# COPY ./letsencrypt.etc /etc/letsencrypt
# COPY /letsencrypt /usr/local/letsencrypt

RUN wget -q -O /etc/ssl/nginx/CA.crt https://cs.nginx.com/static/files/CA.crt && \
	wget -q -O - http://nginx.org/keys/nginx_signing.key | apt-key add - && \
	wget -q -O /etc/apt/apt.conf.d/90nginx https://cs.nginx.com/static/files/90nginx && \
	printf "deb https://plus-pkgs.nginx.com/debian `lsb_release -cs` nginx-plus\n" >/etc/apt/sources.list.d/nginx-plus.list

#Install NGINX Plus
RUN apt-get update && apt-get install -y nginx-plus

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
	ln -sf /dev/stderr /var/log/nginx/error.log

COPY nginx.conf /etc/nginx/nginx.conf
COPY ./nginx-gz.conf /etc/nginx/
COPY ./nginx-ssl.conf /etc/nginx/

RUN mkdir /tmp/sockets

# Install Amplify
RUN curl -sS -L -O  https://github.com/nginxinc/nginx-amplify-agent/raw/master/packages/install.sh && \
	API_KEY='0202c79a3d8411fcf82b35bc3d458f7e' AMPLIFY_HOSTNAME='mesos-album-manager' sh ./install.sh

COPY ./status.html /usr/share/nginx/html/status.html

EXPOSE 80

CMD ["./start.sh"]