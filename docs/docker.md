# Docker (basics)

## Check docker network list

```bash
docker network ls
```

## Update docker images

```bash
docker compose pull
docker compose up --force-recreate --build -d
docker image prune -f
```

## Remove all docker containers

```bash
docker compose down
docker container prune -f
```

## Remove all docker images

```bash
docker image prune -a -f
```

## Remove all docker volumes

```bash
docker volume prune -f
```

## Remove all docker networks

```bash
docker network prune -f
```

## Remove all docker system

```bash
docker system prune -a -f
docker volume ls
docker volume rm $(docker volume ls -qf dangling=true)
```
