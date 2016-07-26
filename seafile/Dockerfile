FROM centos:centos7.2.1511
MAINTAINER YetAnotherMinion <yam@thinkalexandria.com>

# Change the download locations if you prefer to use a different
# mirror
ENV 	LIBEVHTP_DL_LOC="https://github.com/ellzey/libevhtp/archive/1.1.6.tar.gz" \
	LIBZDB_DL_LOC="http://www.tildeslash.com/libzdb/dist/libzdb-2.12.tar.gz" \
	POSTGRES_REPO="https://download.postgresql.org/pub/repos/yum/9.5/redhat/rhel-7-x86_64/pgdg-centos95-9.5-2.noarch.rpm" \
	LIBSEARPC_DL_LOC="https://github.com/haiwen/libsearpc/archive/v3.0.7.tar.gz" \
	CCNET_DL_LOC="https://github.com/haiwen/ccnet/archive/v5.1.3-server.tar.gz" \
	SEAFILE_DL_LOC="https://github.com/haiwen/seafile/archive/v5.1.3-server.tar.gz" \
	SEAHUB_DL_LOC="https://github.com/haiwen/seahub/archive/v5.1.3-server.tar.gz" \
	\
	SEAFILE_PREFIX=/data/haiwen

# install epel to get re2c and python-pip
RUN yum -y install epel-release
RUN yum -y --nogpgcheck update

RUN yum -y --nogpgcheck install gcc-4.8.5-4.el7 \
	gcc-c++-4.8.5-4.el7 \
	libevent-devel-2.0.21-4.el7 \
	libcurl-devel \
	glib2-devel-2.42.2-5.el7 \
	libuuid-devel-2.23.2-26.el7_2.2 \
	intltool-0.50.2-6.el7 \
	sqlite-devel-3.7.17-8.el7 \
	mariadb-devel \
	mariadb-libs \
	libarchive-devel-3.1.2-7.el7 \
	libtool-2.4.2-21.el7_2 \
	jansson-devel-2.4-6.el7 \
	vala-0.26.1-3.el7 \
	fuse-devel-2.9.2-6.el7 \
	python-2.7.5-34.el7 \
	python-devel-2.7.5-34.el7 \
	openssl-devel-1.0.1e-51.el7_2.5 \
	re2c-0.14.3-2.el7 \
	flex-devel-2.5.37-3.el7 \
	flex-2.5.37-3.el7 \
	libjpeg-turbo-devel-1.2.90-5.el7 \
	wget \
	make \
	cmake \
	python-pip \
	which

# install postgres headers to enable postgres support in libzdb
# prevent postgres packages resolving to postgres supplied
# by the base repository
RUN 	sed -i.bak /etc/yum.repos.d/CentOS-Base.repo -e '/^\[base\]$/a\
exclude=postgresql*' && \
	sed -i.bak /etc/yum.repos.d/CentOS-Base.repo -e '/^\[updates\]$/a\
exclude=postgresql*'

RUN yum -y localinstall $POSTGRES_REPO
RUN yum -y install postgresql95-devel && \
	ln -sf /usr/pgsql-9.5/bin/pg_config /usr/local/bin/pg_config


# install libzdb by building from source
RUN TEMP=$(mktemp -d) && \
	cd $TEMP && \
	wget $LIBZDB_DL_LOC && \
	tar -xzf libzdb-2.12.tar.gz && \
	cd libzdb-2.12 && \
	./configure && \
	make && \
	make install && \
	cd $HOME && \
	rm -rf $TEMP

# install libevhtp
RUN TEMP=$(mktemp -d) && \
	cd $TEMP && \
	wget $LIBEVHTP_DL_LOC && \
	tar -xzf 1.1.6.tar.gz && \
	cd libevhtp-1.1.6 && \
	cmake -DEVHTP_DISABLE_SSL=ON -DEVHTP_BUILD_SHARED=ON . && \
	make && \
	make install && \
	cd $HOME && \
	rm -rf $TEMP
	
# install python dependencies
COPY requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip && \
	pip install -r /tmp/requirements.txt

# prepare directory layout
RUN mkdir -p ${SEAFILE_PREFIX}/seafile-server/src

# get the source of seafile
RUN TEMP=$(mktemp -d) && \
	cd $TEMP && \
	wget -O libsearpc-v3.0.7.tar.gz ${LIBSEARPC_DL_LOC} && \
	wget -O ccnet-v5.1.3-server.tar.gz ${CCNET_DL_LOC} && \
	wget -O seafile-v5.1.3-server.tar.gz ${SEAFILE_DL_LOC} && \
	wget -O seahub-v5.1.3-server.tar.gz ${SEAHUB_DL_LOC} && \
	cd ${SEAFILE_PREFIX}/seafile-server/src && \
	tar -xzf $TEMP/libsearpc-v3.0.7.tar.gz && \
	tar -xzf $TEMP/ccnet-v5.1.3-server.tar.gz && \
	tar -xzf $TEMP/seafile-v5.1.3-server.tar.gz && \
	cd ${SEAFILE_PREFIX}/seafile-server && \
	tar -xzf $TEMP/seahub-v5.1.3-server.tar.gz && \
	mv seahub-5.1.3-server seahub && \
	rm -rf $TEMP

# build the seafile server
RUN cd ${SEAFILE_PREFIX}/seafile-server/src/libsearpc-3.0.7 && \
	./autogen.sh && \
	./configure && \
	make && \
	make install && \
	cd ${SEAFILE_PREFIX}/seafile-server/src/ccnet-5.1.3-server && \
	./autogen.sh && \
	export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig && \
	./configure --disable-client --enable-server && \
	make && \
	make install && \
	cd ${SEAFILE_PREFIX}/seafile-server/src/seafile-5.1.3-server && \
	./autogen.sh && \
	./configure --disable-client --enable-server && \
	make && \
	make install && \
	ldconfig

# seafile server installs python packages into /usr/local/lib64/ by default
# add the seafile-server third party packages to the path as well
ENV 	PYTHONPATH=$PYTHONPATH:/usr/lib/python2.7/site-packages:/usr/local/lib64/python2.7/site-packages:${SEAFILE_PREFIX}/seafile-server/seahub/thirdpart \
	CCNET_CONF_DIR=${SEAFILE_PREFIX}/ccnet \
	SEAFILE_CONF_DIR=${SEAFILE_PREFIX}/conf \
	SEAFILE_CENTRAL_CONF_DIR=${SEAFILE_CONF_DIR}

COPY seafile_setup.sh ${SEAFILE_PREFIX}/seafile_setup.sh
RUN cd ${SEAFILE_PREFIX} && ./seafile_setup.sh

EXPOSE 10001 12001 8082 8000


