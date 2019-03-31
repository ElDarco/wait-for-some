## wait-for-some
`wait-for-some.sh` is a pure bash script waiting for a positive execution of the command, before the execution of the main command.
Can be used to delay the launch of docker container, and synchronize them.

## Usage

```

-h          | --help                Request help
-c COMMAND  | --cmd=COMMAND         Command "check" pending exit code 0
-t TIMEOUT  | --timeout=TIMEOUT     The time allocated for the execution of the verification command.
                                    If the team will work longer than the specified time, the attempt will be considered unsuccessful. (s) (default:5)
-i INTERVAL | --interval=INTERVAL   Sets the interval between the start, the first check and the next check (s) (default:5)
-r RETRIES  | --retries=RETRIES     The number of attempts before exiting the script with an error. (default:3)

-- COMMAND ARGS                     Execute command with args after the test finishes

```

## Example

```

./wait-for-some.sh --cmd="ls -la | grep README.md" -t 10 -i 5 -r 10 -- echo 123

waiting for execution: ls -la | grep README.md
timeout: 10
interval: 5
retries: 10

waiting with a interval
success
123

```

## Example in docker-compose.yml
```yaml
version: '2'
services:
  nginx:
    image: nginx
    command: sh -c ./wait-for-some.sh --cmd="ls -la /var/www/dist | grep index.html" -- nginx -g 'daemon off;'
    depends_on:
      - nodejs
    volumes:
      - ./src:/var/www
  nodejs:
    image: node:8
    command: /bin/bash -c "npm run build:prod"
    volumes:
      - ./src:/var/www
```