# rastamalik_microservices

## Homework-20
1. Создадим новый проект **example2**, добавим новый **remote**:
```
 git checkout -b docker-7
 git remote add gitlab2 http://<your-vm-ip>/homework/example2.git 
 git push gitlab2 docker-7
```
2. Изменим пайплайн таким образом, чтобы **job deploy** стал определением окружения **dev**, на которое условно будет выкатываться каждое изменение в коде проекта.
3. Изменим **.gitlab-ci.yml**:
```
image: ruby:2.4.2

stages:
  - build
  - test
  - deploy
  - review
  - stage
  - production


variables:
  DATABASE_URL: 'mongodb://mongo/user_posts'

before_script:
  - cd reddit
  - bundle install

build_job:
  stage: build
  script:
    - echo 'Building'
test_unit_job:
  stage: test
  services:
    - mongo:latest
  script:
    - ruby simpletest.rb
test_integration_job:
  stage: test
  script:
    - echo 'Testing 2'
deploy_dev_job:
  stage: review
  script:
    - echo 'Deploy'
  environment:
    name: dev
    url: http://dev.example.com
branch review:
  stage: review
  script: echo "Deploy to $CI_ENVIRONMENT_SLUG"
  environment:
    name: branch/$CI_COMMIT_REF_NAME
    on_stop: stop_branch
    url: http://$CI_ENVIRONMENT_SLUG.example

  only:
    - branches
  except:
    - master

staging:
  stage: stage
  when: manual
  only:
    - /^\d+\.\d+.\d+/
  script:
    - echo 'Deploy'
  environment:
    name: stage
    url: https://beta.example.com

production:
  stage: production
  when: manual
  only:
      - /^\d+\.\d+.\d+/
  script:
    - echo 'Deploy'
  environment:
    name: production
    url: https://example.com
```    

4. На странице окружений должны появиться окружения **staging и production**.
5. Условия и ограничения, добавим в описание pipeline директиву, которая не позволит нам выкатить на staging и зкщвгсешщт код, не помеченный с помощью тэга в git.
```
staging:
  stage: stage
  when: manual
  only:
    - /^\d+\.\d+.\d+/
  script:
    - echo 'Deploy'
  environment:
    name: stage
    url: https://beta.example.com

production:
  stage: production
  when: manual
  only:
      - /^\d+\.\d+.\d+/
  script:
    - echo 'Deploy'
  environment:
    name: production
    url: https://example.com
```
Измеение, помеченное тэгом в git запустит полный пайплайн
```
git commit -a -m ‘#4 add logout button to profile page’
git tag 2.4.10
git push gitlab2 docker-7 --tags
```
6.Динамические окружения, добавленный ниже **job** определяет динамическое окружение для каждой ветки в репозитории, кроме ветки master:
```
branch review:
  stage: review
  script: echo "Deploy to $CI_ENVIRONMENT_SLUG"
  environment:
    name: branch/$CI_COMMIT_REF_NAME
    on_stop: stop_branch
    url: http://$CI_ENVIRONMENT_SLUG.example

  only:
    - branches
  except:
    - master
    ```
  




## Homework-19
1. Создаем виртуальную машину на Google Cloud **gitlab-ci**.
2. На созданной машине установим **Docker**.
3. На новом сервере создадим директории и поготовим **docker-compose.yml**.
```
 mkdir -p /srv/gitlab/config /srv/gitlab/data /srv/gitlab/logs
 cd /srv/gitlab/
 touch docker-compose.yml
```
```
docker-compose.yml
---
web:
  image: 'gitlab/gitlab-ce:latest'
  restart: always
  hostname: 'gitlab.example.com'
  environment:
    GITLAB_OMNIBUS_CONFIG: |
      external_url 'http://<YOUR-VM-IP>'
  ports:
    - '80:80'
    - '443:443'
    - '2222:22'
  volumes:
    - '/srv/gitlab/config:/etc/gitlab'
    - '/srv/gitlab/logs:/var/log/gitlab'
- '/srv/gitlab/data:/var/opt/gitlab'
```
4. Настраиваем Gitlab CI, создаем новый проект **example**, и выполняем команды:
```
git checkout -b docker-6
git remote add gitlab 
http://<your-vm-ip>/homework/example.git 
git push gitlab docker-6
```
5. Определяем Pipeline для проекта, в репозиторий добавим файл **.gitlab-ci.yml**
```
stages:
  - build
  - test
  - deploy

build_job:
  stage: build
  script:
    - echo 'Building'

test_unit_job:
  stage: test
  script:
    - echo 'Testing 1'

test_integration_job:
  stage: test
  script:
    - echo 'Testing 2'

deploy_job:
  stage: deploy
  script:
- echo 'Deploy'
```

6. Для запуска **pipeline** создадим **runner**, на сервере **gitlab-ci** выполним команду:
```
docker run -d --name gitlab-runner --restart always \ 
-v /srv/gitlab-runner/config:/etc/gitlab-runner \ 
-v /var/run/docker.sock:/var/run/docker.sock \ 
gitlab/gitlab-runner:latest 
```
Зарегистрируем **runner** командой:
```
docker exec -it gitlab-runner gitlab-runner register
```
7. Добавим исходный код reddit в репозиторий:
```
git clone https://github.com/express42/reddit.git  && rm -rf ./reddit/.git
git add reddit / 
git commit -m “Add reddit app” 
git push gitlab  docker-6
```
8. Добавим тест для **reddit**, в папке **reddit** создадим файл **simpletest.rb**:
```
require_relative './app'
require 'test/unit'
require 'rack/test'

set :environment, :test

class MyAppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_get_request
    get '/'
    assert last_response.ok?
  end
end
```
9. Добавим библиотеку для тестирования в **reddit/Gemfile**, добавим ``` gem 'rack-test' ```.





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

