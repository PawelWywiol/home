# GlitchTip

### DOCS

[installation guide](https://glitchtip.com/documentation/install)

[containers.fun article](https://containers.fan/posts/setup-glitchtip-exception-logging-on-docker/)

### SuperUser

To create a superuser for the GlitchTip application, run the following command:

```shell
docker-compose run glitchtip_migrate ./manage.py createsuperuser
```

or login to the glitchtip_migrate container and run the command directly:

```shell
docker exec -it glitchtip_migrate /bin/bash

./manage.py createsuperuser
```