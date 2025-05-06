# x250

## WSL2 with docker on Windows startup without login

- open `Task Scheduler`
- create a new task
- set the task to run with highest privileges
- set the task to run when the computer starts
- set the task to run `wsl`

### Troubleshooting

```
error getting credentials - err: exec: "docker-credential-desktop.exe": executable file not found in $PATH, out: ``
```

Edit `.docker/config.json` (on wsl) and replace the line with `credsStore` with `credStore`

## Generate a new random key

```bash
openssl rand -base64 32
```
