### Original Project that much of this was cloned from.

http://www.dockerwordpress.com/docker/upgrading-wordpress-docker

## Base image for PHP developer using MongoDB, Composer, Redis


### Includes an NGINX, PHP-FPM, PHP-CLI
Lots of fat

### Setup

Copy your project to /DATA

expects a /htdocs directory
expects a /htdocs/index.php

## Not for production usage

Example use

```bash
mkdir hello-php

cd hello-php

mkdir htdocs

sudo echo "<?php
echo \"hello php\";
" > ./htdocs/index.php
```

Dockerfile
```docker
FROM docbradfordsoftware/php7-dev:1.0
MAINTAINER jkevlin<jkevlin@gmail.com>

WORKDIR /
COPY ./htdocs /DATA/htdocs

CMD ["/run.sh"]
```

```bash
DOCKERHUB_USER=<your-username>
docker build -t $DOCKERHUB_USER/hello-php:1.0 .

docker run -p 49000:80 --rm --name hello-php $DOCKERHUB_USER/hello-php:1.0
```

use docker-machine to find your local ip (on a MAC use localhost)
usually it is locaed at 192.168.99.100
```bash
docker-machine ip
```

In a browser naviate to
localhost:49000
or
192.168.99.100:49000

### Stop the container
In another terminal window
```bash
docker stop hello-php
```

