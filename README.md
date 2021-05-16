## Django On Docker Using Nginx As A Reverse Proxy
### Django application in dev mode
This project is is using Nginx configured as a reverse proxy, in front of the Django application while also Nginx is serving all static assets from the static directory. Except from the standared docker-compose file, it includes a docker-compose debug file with all the nessesery settings located inside the .vscode folder. Data persistance is also provided by volume use.

Project structure:
```
├── .vscode
    ├── launch.json
    ├── settings.json
    └── tasks.json
├── app
    ├── app
        ├── static
        ├── __init__.py
        ├── asgi.py
        ├── settings.py
        ├── urls.py
        ├── views.py
        └── wsgi.py
    ├── db.sqlite3
    └── manage.py
├── proxy
    ├── nginx.conf
├── docker-compose.yaml
├── docker-compose.debug.yaml
├── variables
    └── .django.env
├── Dockerfile
├── README.md
├── requirements.txt
```

[_docker-compose.yml_](docker-compose.yml)
```
version: '3.4'

services:
  app:
    image: django
    container_name: django
    hostname: django
    restart: always
    env_file: variables/.django.env
    build:
      context: .
      dockerfile: ./Dockerfile
    volumes:
      - ./app:/app
    command: python manage.py runserver 0.0.0.0:8000
    networks:
      - default

  proxy:
    depends_on:
      - app
    image: admintuts/nginx:1.20.0-rtmp-geoip2-alpine
    container_name: proxy
    hostname: proxy
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./proxy/nginx.conf:/etc/nginx/nginx.conf
      - ./app/app/static:/etc/nginx/static
    networks:
      - default

volumes:
  app:
  proxy:

networks:
  default:
    driver: bridge

volumes:
  app:
  proxy:

networks:
  default:
    driver: bridge
```

## Deploy with docker-compose

```
$ git clone https://github.com/sceptic30/docker-compose-django.git
$ sudo chown 1001:$(id -g) -R docker-compose-django
$ sudo chmod 770 -R docker-compose-django
$ sudo chmod 744 -R docker-compose-django/proxy
$ sudo chmod 755 -R docker-compose-django/app/app/static
$ docker-compose up
Creating network "docker-compose-django_default" with driver "bridge"
Creating django ... done
Creating proxy  ... done
Attaching to django, proxy
proxy    | /docker-entrypoint.sh: performing configuration based on scripts found in /docker-entrypoint.d/
proxy    | /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
proxy    | /docker-entrypoint.sh: Launching /docker-entrypoint.d/envsubst-on-templates.sh
proxy    | /docker-entrypoint.sh: Launching /docker-entrypoint.d/tune-worker-processes.sh
proxy    | /docker-entrypoint.sh: Entrypoint operations complete. Ready to load binary.
django   | Watching for file changes with StatReloader
django   | Performing system checks...
django   | 
django   | System check identified no issues (0 silenced).
django   | 
django   | You have 18 unapplied migration(s). Your project may not work properly until you apply the migrations for app(s): admin, auth, contenttypes, sessions.
django   | Run 'python manage.py migrate' to apply them.
django   | May 15, 2021 - 15:52:30
django   | Django version 3.2.3, using settings 'app.settings'
django   | Starting development server at http://0.0.0.0:8000/
django   | Quit the server with CONTROL-C.

```
## Apply Migrations
Execute the command below:
```
docker exec -it django sh -c "python manage.py migrate"
```

## Create A SuperUser
```
docker exec -it django sh -c "python manage.py createsuperuser"
```

## Expected result

Listing containers will show 2 containers running and the port mappings as below:
```
$ docker ps
CONTAINER ID   IMAGE                                       COMMAND                  CREATED         STATUS         PORTS                                                                                          NAMES
8376f8d9968f   admintuts/nginx:1.20.0-rtmp-geoip2-alpine   "/docker-entrypoint.…"   3 minutes ago   Up 3 minutes   0.0.0.0:80->80/tcp, :::80->80/tcp, 3080/tcp, 0.0.0.0:443->443/tcp, :::443->443/tcp, 3443/tcp   proxy
e176c013850f   django                                      "python manage.py ru…"   3 minutes ago   Up 3 minutes   8000/tcp                                                                                       django
```

## Verify Installation
After the application starts, navigate to `http://localhost` in your web browser:

## Debugging
Debugging configuration is already included in the vscode folder. All you have to do is hit F5, and will automatically start.

## Stop and remove the containers
```
$ docker-compose down
```
