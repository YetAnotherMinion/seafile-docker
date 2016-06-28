create database `ccnet-db` character set = 'utf8';
create database `seafile-db` character set = 'utf8';
create database `seahub-db` character set = 'utf8';

create user 'seafile'@'seafile01' identified by 'seafile';

GRANT ALL PRIVILEGES ON `ccnet-db`.* to `seafile`@seafile01;
GRANT ALL PRIVILEGES ON `seafile-db`.* to `seafile`@seafile01;
GRANT ALL PRIVILEGES ON `seahub-db`.* to `seafile`@seafile01;

