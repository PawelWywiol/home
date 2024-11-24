# Scripts

## init-docker-lxc.sh

### On container

Run script on container

Reset the `code` user password

```shell
passwd code
```

### On your machine

Remove previous entry from `~/.ssh/known_hosts`

```shell
ssh-keygen -R 192.168.0.XXX
```

Add your public key to the lxc `authorized_keys`

```shell
ssh-copy-id code@192.168.0.XXX
```

Update your `~/.ssh/config`

```shell
code ~/.ssh/config
```

```shell
Host local-traefik
HostName 192.168.0.XXX
User code
```