CONFIG ?= config
include $(CONFIG).mk


.PHONY: dev seafile_nginx seafile_mariadb seafile_seafile

all: seafile_nginx seafile_mariadb seafile_seafile

seafile_nginx: nginx/Dockerfile
	make -C nginx registry=$(registry)

seafile_mariadb: mariadb/Dockerfile
	make -C mariadb registry=$(registry)

seafile_seafile: seafile/Dockerfile
	make -C seafile registry=$(registry)

# Remove the images
.PHONY: clean
clean:
	docker rmi seafile_seafile seafile_mariadb seafile_nginx
