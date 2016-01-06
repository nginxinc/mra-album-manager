name = ngrefarch/ngra-album-manager
volumes = -v $(CURDIR):/usr/src/app
ports = -p 80:80

build:
	docker build -t $(name) .

run:
	docker run -it --env-file=.env ${ports} $(name)

run-v:
	docker run -it --env-file=.env ${ports} $(volumes) $(name)

shell:
	docker run -it --env-file=.env ${ports} $(volumes) $(name) bash

push:
	docker push $(name)

test:
	docker run -it ${ports} $(volumes) $(name) bundle exec rspec