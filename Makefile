CONFIG ?= config.mk
include $(CONFIG)


.PHONY: dev seafile_nginx seafile_mariadb seafile_seafile

all: seafile_nginx seafile_mariadb seafile

# the db image needs to be available before the seafile installation starts
seafile: seafile_mariadb
	make -C seafile registry=$(registry)

seafile_nginx:
	make -C nginx registry=$(registry)

seafile_mariadb:
	make -C mariadb registry=$(registry)


# Remove the images
.PHONY: clean
clean: clean_seafile clean_nginx clean_mariadb

clean_seafile:
	make -C seafile registry=$(registry) clean

clean_nginx:
	make -C seafile registry=$(registry) clean

clean_mariadb:
	make -C mariadb registry=$(registry) clean
