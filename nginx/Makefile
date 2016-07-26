ifdef registry
image_name=$(registry)/seafile_nginx
else
image_name=seafile_nginx
endif


all: Dockerfile
	sudo docker build --rm -t $(image_name) .

no_cache: Dockerfile
	sudo docker build --rm --no-cache -t $(image_name) .

.PHONY: clean

clean:
	sudo docker rmi $(image_name)

