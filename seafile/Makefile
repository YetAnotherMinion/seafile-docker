ifdef registry
image_name=$(registry)/seafile
else
image_name=seafile
endif


all:
	sudo docker build --rm -t $(image_name) .

no_cache:
	sudo docker build --rm --no-cache -t $(image_name) .

.PHONY: clean

clean:
	sudo docker rmi $(image_name)

