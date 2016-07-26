# set -x


# these environment variables are needed for the manage.py to work
# by default they should be supplied by the Dockerfile
: ${SEAFILE_PREFIX:=/data/haiwen}
: ${CCNET_CONF_DIR:=${SEAFILE_PREFIX}/ccnet}
: ${SEAFILE_CONF_DIR:=${SEAFILE_PREFIX}/conf}
: ${SEAFILE_CENTRAL_CONF_DIR:=${SEAFILE_CONF_DIR}}

# need to export this variable so that the python module seaserv
# can find the configuration file for ccnet. seaserv will fall back to searching
# CCNET_CONF_DIR if SEAFILE_CENTRAL_CONF_DIR is not set, which will cause the
# manage.py script to fail because we are using a central config directory
export -p SEAFILE_CENTRAL_CONF_DIR

#################################################
#	Generate config folders and files
#################################################

# order matters
ccnet-init \
	-F $SEAFILE_CONF_DIR \
	-c $CCNET_CONF_DIR \
	--name foobar \
	--port 10001 \
	--host seafile.devthink.xyz

seaf-server-init \
	-F $SEAFILE_CONF_DIR \
	--seafile-dir ${SEAFILE_PREFIX}/seafile-data \
	--port 12001 \
	--fileserver-port 8082

echo "${SEAFILE_PREFIX}/seafile-data" > ${CCNET_CONF_DIR}/seafile.ini


# worry about how to generate the secret key later
secret_key="cc950851-51b1-4992-ac55-ec5eeb424cfb98f0"
echo "SECRET_KEY = \"$secret_key\"" > ${SEAFILE_CONF_DIR}/seahub_settings.py
# email setup
echo "EMAIL_USE_TLS = True" > ${SEAFILE_CONF_DIR}/seahub_settings.py
echo "EMAIL_HOST = \"smtp.example.com\"" > ${SEAFILE_CONF_DIR}/seahub_settings.py
echo "EMAIL_HOST_USER = \"username@example.com\"" > ${SEAFILE_CONF_DIR}/seahub_settings.py
echo "EMAIL_HOST_PASSWORD = \"password\"" > ${SEAFILE_CONF_DIR}/seahub_settings.py
echo "EMAIL_PORT = 587" > ${SEAFILE_CONF_DIR}/seahub_settings.py
echo "DEFAULT_FROM_EMAIL = \"username@example.com\"" > ${SEAFILE_CONF_DIR}/seahub_settings.py
echo "SERVER_EMAIL = \"username@example.com\"" > ${SEAFILE_CONF_DIR}/seahub_settings.py

###### create gunicorn config
mkdir -p ${SEAFILE_PREFIX}/seafile-server/runtime/
echo '
import os
daemon = True
workers = 3

# Logging
runtime_dir = os.path.dirname(__file__)
pidfile = os.path.join(runtime_dir, "seahub.pid")
errorlog = os.path.join(runtime_dir, "error.log")
accesslog = os.path.join(runtime_dir, "access.log")
' > ${SEAFILE_PREFIX}/seafile-server/runtime/seahub.conf

#################################################
#	Setup that database
#################################################

# the manage.py is not compatible with
cd /data/haiwen/seafile-server/seahub
python manage.py syncdb
cd ${SEAFILE_PREFIX}

# move the avatars dir outside of the seahub dir
outside_dir=${SEAFILE_PREFIX}/seahub-data/avatars
inside_dir=${SEAFILE_PREFIX}/seafile-server/seahub/media/avatars

mkdir -p $outside_dir
mv $inside_dir $outside_dir
ln -s $outside_dir $inside_dir

