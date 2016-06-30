# seafile-docker
Seafile with MariaDB and Nginx all as one docker-compose

We use a two stage build step. First we use docker compose to build and
link the seafile and database container over the network. Now that the 
containers can talk with each other over a private bridge, we run a 
database setup script. After the database has been configured, we stop the
containers, and save the containers as new images. Then a second docker 
compose is used to manage the running the configured system. The second 
docker compose lacks a build instruction, and only specifies images by name.
We can then create other  docker-compose recipies to perform database 
upgrades and version migrations in the same way as we did the first stage 
build. The top level docker-compose only knows about how to run the services
together after the setup, while the makefile drives the appropriate first 
stage docker compose files as a build step.
