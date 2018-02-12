# rastamalik_microservices

## Homework 16
1. Создадим директорию **docker-monolith** и перенесем туда файлы с прошлых ДЗ.
2. Скачаем reddit-microservice.zip и распакуем его, удали архив.
3. Создадим сервис **post-py**, файл ```./post-py/Dockerfile```:
```
FROM python:3.6.0-alpine

WORKDIR /app
ADD . /app

RUN pip install -r /app/requirements.txt

ENV POST_DATABASE_HOST post_db
ENV POST_DATABASE posts

ENTRYPOINT ["python3", "post_app.py"]
```
4. Создадим сервис **comment**, файл ``` ./comment/Dockerfile```:
```
FROM ruby:2.2
RUN apt-get update -qq && apt-get install -y build-essential

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME

ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments

CMD ["puma"]
```
5. Создадим сервис **ui**, файл ``` ./ui/Dockerfile```:
```
FROM ruby:2.2
RUN apt-get update -qq && apt-get install -y build-essential

ENV APP_HOME /app
RUN mkdir $APP_HOME

WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME

ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292

CMD ["puma"]
```
6. Сборка приложения, скачаем образ mongodb ```docker pull mongo:latest```.
  Соберем образа с нашими сервисами:
  ```
  docker build -t rastamalik/post:1.0 ./post-py
  docker build -t rastamalik/comment:1.0 ./comment
  docker build -t rastamalik/ui:1.0 ./ui
```
7. Запуск приложения.
Создадим сеть ```docker network create reddit```
Запустим контейнеры:
```
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post <your-dockerhub-login>/post:1.0
docker run -d --network=reddit --network-alias=comment <your-dockerhub-login>/comment:1.0
docker run -d --network=reddit -p 9292:9292 <your-dockerhub-login>/ui:1.0

```
8. Серви **ui** - улучшаем образ, поменяем содержимое ```./ui/Dockerfile```:
```
FROM ubuntu:16.04
RUN apt-get update \
    && apt-get install -y ruby-full ruby-dev build-essential \
    && gem install bundler --no-ri --no-rdoc

ENV APP_HOME /app
RUN mkdir $APP_HOME

WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME

ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292

CMD ["puma"]
```
9. Пересоберем **ui** ```docker build -t <your-login>/ui:2.0 ./ui```, посмотрим что получилось ```docker images```:
```
REPOSITORY           TAG                 IMAGE ID            CREATED             SIZE

rastamalik/ui        2.0                 91b317af243d        20 hours ago        453MB
rastamalik/ui        1.0                 dd58333ee713        20 hours ago        775MB
```
10. Пересоберем образ на основе **Alpine linux** поменяем содержимое ```./ui/Dockerfile```:
```
FROM alpine:latest
ENV RUBY_VERSION 2.4.2
ENV BUNDLER_VERSION 1.15.4
ENV BUNDLE_SILENCE_ROOT_WARNING=1

RUN mkdir -p /usr/local/etc \
  && { \
    echo 'install: --no-document'; \
    echo 'update: --no-document'; \
} >> /etc/gemrc

RUN apk update && apk add --no-cache \
    ruby \
    ruby-dev \
    ruby-json \
    ruby-bigdecimal \
    build-base\
    libssl1.0 \
    libc6-compat
RUN gem install bundler --version "$BUNDLER_VERSION"
RUN bundler config --global build.nokogiri --use-system-libraries


ENV APP_HOME /app
RUN mkdir $APP_HOME

WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME

ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292

CMD ["puma"]

```
```docker build -t rastamalik/ui:3.0 ./ui```

Вывод команды ```docker images```:
```
REPOSITORY           TAG                 IMAGE ID            CREATED             SIZE
rastamalik/ui        3.0                 2f55186b35bd        19 hours ago        207MB
rastamalik/ui        2.0                 91b317af243d        20 hours ago        453MB
rastamalik/ui        1.0                 dd58333ee713        20 hours ago        775MB
```
9. Создадим **docker volume** ```docker volume create reddit_db``` и подключим его к **mongodb**:
```
docker kill $(docker ps -q)
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post <your-dockerhub-login>/post:1.0
docker run -d --network=reddit --network-alias=comment <your-dockerhub-login>/comment:1.0
docker run -d --network=reddit -p 9292:9292 <your-dockerhub-login>/ui:2.0
```





## Homework-15
1. Устанавливаем **docker-machine**.
2. Создаем новый проект на **Google Cloud** названием **docker**.
3. Устанавливаем GCloud SDK.
4. Сконфигурируем **gcloud**
```
gcloud init
```
5. Запускаем команду ```gcloud auth``` для работы с облаком  **docker-machine**.
6. Создаем **docker-machine**:
```
docker-machine create --driver google \                 
--google-project docker-193613 \
--google-zone europe-west1-b \
--google-machine-type g1-small \
--google-machine-image $(gcloud compute images list --filter ubuntu-1604-lts --uri) \
docker-host
```
7. Создаем образ с приложением, **Dockerfile**:
```
FROM ubuntu:16.04
RUN apt-get update
RUN apt-get install -y mongodb-server ruby-full ruby-dev build-essential git 
RUN gem install bundler 
RUN git clone https://github.com/Artemmkin/reddit.git

COPY mongod.conf /etc/mongod.conf
COPY db_config /reddit/db_config
COPY start.sh /start.sh

RUN cd /reddit && bundle install
RUN chmod 0777 /start.sh 

CMD ["/start.sh"]

```

8. Собираем образ:
```
docker build -t reddit:latest .
```
9. Запустим контейнер:
```
docker run --name reddit -d --network=host reddit:latest
```
10. Разрешим входящий  TCP-трафик на порт  9292 выполнив команду:
```
gcloud compute firewall-rules create reddit-app \       
--allow tcp:9292 --priority=65534 \
--target-tags=docker-machine \
--description="Allow TCP connections" \
--direction=INGRESS
```
11. Проверим работу приложения по внешнему IP.
12. Загрузим наш образ на **docker hub**:
```
docker tag reddit:latest rastamalik/otus-reddit:1.0
docker push rastamalik/otus-reddit:1.0
```




## Homework-14
1. Устанавливаем Docker, по инструкции
2. Запускаем первый контейнер:
```
docker run hello-world
```
3.Запустим контейнер из image
```
docker run -it ubuntu:16.04 /bin/bash
root@8d0234c50f77:/# echo 'Hello world!' > /tmp/file
root@8d0234c50f77:/# exit
```
4. Найдем ранее созданный контейнер в котором создали **/tmp/file**
```
docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Names}}" 
```
5. Запускаем контейнер и посединяемся к нему:
```
docker start  <u_container_id>
docker attach <u_container_id>
ENTER
root@<u_container_id>:/#
root@<u_container_id>:/# cat /tmp/file
Hello world!

```
6. Создаем commit:
```
docker commit <u_container_id>   rastamalik/ubuntu-tmp-file
```
7. **docker images**:
```
REPOSITORY                   TAG                 IMAGE ID            CREATED             SIZE
rastamalik/ubuntu-tmp-file   latest              3075516a151a        4 minutes ago       112MB
ubuntu                       16.04               0458a4468cbc        3 days ago          112MB
hello-world                  latest              f2a91732366c        2 months ago        1.85kB
```
8. Удаляем все контейнеры
```
docker rm $(docker ps -a -q) # 
docker rmi $(docker images -q)                                                                                                                       
```

