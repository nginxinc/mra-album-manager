name = ngrefarch/ngra-album-manager
volumes = -v $(CURDIR):/app
ports = -p 80:4567

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