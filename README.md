# rastamalik_microservices

## Homework-29
1. Установка **kubectl**
2. Установка **minikube**
3. Запустим **minikube-cluster**.
4. Сконфигурируем **kubectl**
```
1)Создать cluster:
 kubectl config set-cluster ... cluster_name
2)Создать данные пользователя  (credentials)
 kubectl config set-credentials ... user_name
3)Создать контекст
 kubectl config set-context context_name --cluster=cluster_name --user=user_name
4) Использовать контекст
 kubectl config use-context context_name
 ```
5. Запустим приложение **ui-deployment**:
```
kubectl apply -f ui-deployment.yml
```
6. Пробросим сетевой порт POD-а на локальную машину:
```
kubectl get pods --selector component=ui
kubectl port-forward <pod-name> 8080:9292
```
7. Запусти аналогично **post-deployment.yml**, **comment-deployment.yml** и **mongo-deployment.yml**, а также примонтируем стандартный **Volume** для хранения данных вне контейнера.
```
spec:
      containers:
      - image: mongo:3.2
        name: mongo
        volumeMounts:
        - name: mongo-persistent-storage
          mountPath: /data/db
      volumes:
      - name: mongo-persistent-storage
        emptyDir: {}
 ```
 8. Для связи **ui** с **post** и **comment** создадим им по объекту **Service**, **post-service.yml**, **comment-service.yml**, **ui-service.yml** и **mongodb-service**.
 9. Проверяем приложение, пробрасываем порт на **ui pod**:
 ```
 kubectl port-forward <pod-name> 9292:9292
 ```
и заходим на http://localhost:9292

10. Чтобы приложение работало нормально создадим **Ыукмшсу** для БД comment - **comment-mongodb-service.yml**:
```
---
apiVersion: v1
kind: Service
metadata:
  name: comment-db
  labels:
    app: reddit
    component: mongo
    comment-db: "true"
spec:
  ports:
  - port: 27017
    protocol: TCP
    targetPort: 27017
  selector:
    app: reddit
    component: mongo
    comment-db: "true
```
11. Также обновим файл **deployment** для **mongodb**, чтобы новый **Service** смог найти нужный **Pod**:
```
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: mongo
  labels:
    app: reddit
    component: mongo
   comment-db: "true"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: reddit
      component: mongo
  template:
    metadata:
      name: mongo
      labels:
        app: reddit
        component: mongo
        comment-db: "true"
   ```
12. Аналогично сделаем для **post- сервиса**:
```
--
apiVersion: v1
kind: Service
metadata:
  name: post-db
  labels:
    app: reddit
    component: mongo
    post-db: "true"
spec:
  ports:
  - port: 27017
    protocol: TCP
    targetPort: 27017
  selector:
    app: reddit
    component: mongo
    post-db: "true"
```
13. Обеспечим доступ к **ui-сервису** снаружи, с помощью **NodePort и TargetPort**:
```
ui-service.yml
---
apiVersion: v1
kind: Service
metadata:
  name: ui
  labels:
    app: reddit
    component: ui
spec:
  type: NodePort
  ports:
  - nodePort: 32092
    port: 9292
    protocol: TCP
    targetPort: 9292
  selector:
    app: reddit
    component: ui
```

 14. Проверим доступ с помощью ``` minikube service ui```
 
 15. Включим аддон **dashboard** в **minikube**:
 ```
 minikube addons enable dashboard
 ```
 и запустим в браузере: ``` minikube service kubernetes-dashboard -n kube-system ```
 
 16. Развернем **Kubernetes** в Google Cloud используя платформу **Google Kubernetes Engine**.
 
 17. Ссылка на работующее приложение в **GKE** http://35.187.56.64:32092/

## Homework-28
1. Создал **deployment** **post**,**ui**,**comment**,**mongo**.
2. Создал папку **kubernetes**, куда и поместил **.yml** файлы.
3. Создал **kubernetes-кластер** согласно пошаговой инструкции.
4. Создал папку **kubernetes_the_hard_way** куда поместил все серитификаты и ключи.
5. Запустил поды **post**,**ui**,**comment**,**mongo** c помощью команды 
``` 
kubectl apply -f <filename>
```
6. Проверил что поды запустились 
``` 
kubectl get pods --all-namespaces 
```
7.Задание со звездочкой.

8.Создал папку **ansible** куда поместил основные плэйбуки и bash скрипты для разворачивания **kubernetes-кластера**. Для удобства  и пошаговой установки создал **Makefile** (находится в папке ansible) где описал все шаги разворачивания.

## Homework-27
1. Создаем машины **master-1** на GCE и по аналогии **woker-1** и **worker-2**.
2. Строим **swarm cluster**
```
eval $(docker-machine env master-1)
docker swarm init
```
3. Кластер создан и добавим к нему новые ноды
```
eval $(docker-machine env worker-1)
docker swarm join --token <наш токен> <advertise адрес manager’a>:2377
eval $(docker-machine env worker-2)
docker swarm join --token <наш токен> <advertise адрес manager’a>:2377
```
4. Сервисы и их зависимости объединяем в **STACK** описываем в формате **docker-compose**
5. Поднимаем **STACK**
```
docker stack deploy --compose-file=<(docker-compose -f docker-compose.yml config 2>/dev/null) DEV
```

6. Размещаем сервисы по нодам и деплоим
```
docker stack deploy --compose-file=<(docker-compose -f docker-compose.yml config 2>/dev/null) DE
```
7. Масштабируем сервисы:
```
services:
  post:
    image: ${USERNAME}/post:${POST_VERSION}
    deploy:
      mode: replicated
      replicas: 2
      placement:
        constraints:
          - node.role == worker
    networks:
      - front_net
      - back_net

  comment:
    image: ${USERNAME}/comment:${COMMENT_VERSION}
    deploy:
      mode: replicated
      replicas: 2
      placement:
        constraints:
          - node.role == worker
    networks:
      - front_net
      - back_net

  ui:
    image: ${USERNAME}/ui:${UI_VERSION}
    deploy:
      mode: replicated
      replicas: 2
      placement:
        constraints:
          - node.role == worker
    ports:
      - "${UI_PORT}:9292/tcp"
    networks:
      - front_net
  ```
8. Для задач монитроинга запустим **node_exporter**
```
node-exporter: 
    image: prom/node-exporter:
v0.15.0 
deploy: 
      mode: global 
```
9. Добавим в кластер **worker-3**. В контейнере запустиля только **node-exporter**, после увеличения реплик и деплоя, в контейнере поднялся сервис **Post**. При добавлении нового **workera** запустился сразу сервис с **mode: global**, после деплоя на нем запустился сервис с **mode: replicated**.
10. Задание с **update_config**,**ресурсами**,и **политика перезапуска**:
```
version: '3.5'
services:

  mongo:
    image: mongo:${MONGO_VERSION}
    deploy:
      placement:
        constraints:
          - node.labels.reliability == high
    volumes:
      - mongo_data:/data/db
    networks:
      back_net:
        aliases:
          - post_db
          - comment_db

  post:
    image: ${USERNAME}/post:${POST_VERSION}
    deploy:
      restart_policy:
        condition: on-failure
        max_attempts: 15
        delay: 1s
      resources:
        limits:
          cpus: '0.30'
          memory: 300M
      update_config:
        delay: 10s
        parallelism: 2
        failure_action: rollback
      mode: replicated
      replicas: 3
      placement:
        constraints:
          - node.role == worker
    networks:
      - front_net
      - back_net

  comment:
    image: ${USERNAME}/comment:${COMMENT_VERSION}
    deploy:
      restart_policy:
        condition: on-failure
        max_attempts: 15
        delay: 1s
      resources:
        limits:
          cpus: '0.30'
          memory: 300M
      update_config:
        delay: 10s
        parallelism: 2
        failure_action: rollback
      mode: replicated
      replicas: 3
      placement:
        constraints:
          - node.role == worker

    networks:
      - front_net
      - back_net

  ui:
    image: ${USERNAME}/ui:${UI_VERSION}
    deploy:
      restart_policy:
        condition: on-failure
        max_attempts: 3
        delay: 3s
      resources:
        limits:
          cpus: '0.25'
          memory: 150M
      replicas: 3
      update_config:
        delay: 5s
        parallelism: 1
        failure_action: pause
      mode: replicated
      replicas: 3
      placement:
        constraints:
          - node.role == worker
    ports:
      - "${UI_PORT}:9292/tcp"
    networks:
      - front_net

volumes:
  mongo_data: {}

networks:
  back_net: {}
  front_net: {}
  ```
11. Создал **docker-compose.monitoring.yml** для каждого сервиса добавил **mode: global**.


## Homework-25
1.Создаем новую ветку **logging-1**б где и будем выполнять ДЗ.
2.Обновляеи код микросервисов в директории **/src**.
3. Создадим **Docker host** **logging** в GCE.
4. Создаем отдельный compose-файл для логирования **docker/docker-compose-logging.yml** 
```
version: '3'

services:
  zipkin:
    image: openzipkin/zipkin
    ports:
      - "9411:9411"

  fluentd:
    build: ./fluentd
    ports:
      - "24224:24224"
      - "24224:24224/udp"



  elasticsearch:
    image: elasticsearch
    expose:
      - 9200
    ports:
      - "9200:9200"

  kibana:
    image: kibana
    ports:
      - "8080:5601"
   ```
  5. Используем **fluentd** для агрегации и парсинга логов. В директории **docker** создадим директроию **fluentd**, а в ней создадим **Dockerfile** lля сборки и файл конфигурации **fluent.conf**.
  6. Запустим сервисы и выполним команду для просмотров логов **post** ```docker-compose logs -f post```.
  7. Отправим логи во **fluentd** и визуализируем их в **Kibana**.
  8. Используем фильтры для для парсинга логов, приходящих от **post**, добавим их конфиг **fluentd**:
  ```
  <source>
  @type forward
  port 24224
  bind 0.0.0.0
</source>

<filter service.post>
  @type parser
  format json
  key_name log
</filter>

<filter service.ui>
  @type parser
  key_name log
  format grok
  grok_pattern %{RUBY_LOGGER}
</filter>

<filter service.ui>
  @type parser
  format grok
  grok_pattern service=%{WORD:service} \| event=%{WORD:event} \| request_id=%{GREEDYDATA:request_id} \| message='%{GREEDYDATA:message}'
  key_name message
  reserve_data true
</filter>

<match *.**>
  @type copy
  <store>
    @type elasticsearch
    host elasticsearch
    port 9200
    logstash_format true
    logstash_prefix fluentd
    logstash_dateformat %Y%m%d
    include_tag_key true
    type_name access_log
    tag_key @log_name
    flush_interval 1s
  </store>
  <store>
    @type stdout
  </store>
</match>
```
7. По аналогии с **post** сервисом определим для **ui** сервиса, добавим драйвер для логирования **fluentd** в compose-файл.

8. Добавим в **docker-compose-logging.yml** сервис **Zipkin** для логирования распределенного трейсинга.



## Homework-23
1. Оставим описание приложений в **docker-compose.yml**, а мониторинг выделим в отдельный файл **docker-compose-monitoring.yml**
2. Для наблюдения за состоянием наших Docker контейнеров используем **cAdvisor**.
3. Для визуализации метрик из **Prometheus** используем **Grafana**.
4. Создадим директорию **grafana/dashboards**, куда будем помещать шаблоны **.json** дашбордов.
5. Создадим директорию **monitoring/alertmanager**, где создадаим **Dockerfile** и **config.yml** для отправки сообщений в **slack**.
6. Запушем собранные нами образы на **DcokerHub**.
7. В папке **src** создал **Makefile** для сборки образов и отправки их на **DockerHub**.
8. Ссылка на docker-hub https://hub.docker.com/u/rastamalik/





## Homework-21
1. Создадим **docker-host** в GCE.
2. Систему мониторинга Prometheus будем запускать внутри Docker контейнера.
```
docker run --rm -p 9090:9090 -d --name prometheus prom/prometheus:v2.1.0
```
3. По умолчанию сервер слушает на порту 9090, а IP адрес созданной VM можно узнать, используя команду:
```
docker-machine ipvm1
```
4. Откроем в браузере.
5. Остановим контейнер ``` docker stop prometheus```
6. Создадим директорию **monitoring/prometheus**, создадим простой Dockerfile, который будет копировать файл конфигурации с нашей машины внутрь контейнера:
```
FROM prom/prometheus:v2.1.0
ADD prometheus.yml /etc/prometheus/
```
7.Определим конфигурацию, создадим в директории **monitoring/prometheus** файл prometheus.yml:
```
---
global:
  scrape_interval: '5s'

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets:
        - 'localhost:9090'

  - job_name: 'ui'
    static_configs:
      - targets:
        - 'ui:9292'

  - job_name: 'comment'
    static_configs:
      - targets:
- 'comment:9292'
```
8.Соберем образ **prometheus**.
9. Соберем образы микросервисов со встроенным кодом **healthcheck**:
```
for i in ui post-py comment; do cd src/$i; bash docker_build.sh; cd -; done
```
10.Определите в вашем **docker/docker-compose.yml** файле новый сервис:
```
services:
...
  prometheus:
    image: ${USERNAME}/prometheus
    ports:
      - '9090:9090'
    volumes:
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention=1d'

volumes:
  prometheus_data:
```
11. Поднимем сервисы в **docker/docker-compose.yml** ```docker-compose up -d```
12. Воспользуемся **Node экспортер** для сбора информации о работе Docker хоста (виртуалки, где у нас запущены контейнеры) и предоставлению этой информации в **Prometheus.** Node экспортер будем запускать также в контейнере. Определим еще один
сервис в **docker/docker-compose.yml** файле.
```
services:

  node-exporter:
    image: prom/node-exporter:v0.15.2
    user: root
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
- '--collector.filesystem.ignored-mount-points="^/(sys|proc|dev|host|etc)($$|/)"'
```
13. И добавим **job** в **prometheus.yml**:
```
scrape_configs:
...
- job_name: 'node'
static_configs:
- targets:
- 'node-exporter:9100'
```
14. Создание мониторинга **MongoDB**. Я использовал mongo-exporter-**dcu/mongodb-exporter**. В папку **monitoring** клонировал **dcu/mongodb-exporter**, создал образ **mongodb-exporter** ```docker build -t mongodb_exporter .```. В **prometheus.yml** добавил **job**:
```
job_name: 'mongod'
    static_configs:
      - targets:
         - 'mongodb-exporter:9001'
```

В **docker-compose.yml** добавил секцию:
```
mongodb-exporter:
    image: mongodb_exporter
    user: root
    environment:
      MONGODB_URL: "mongodb://comment_db:27017"
    networks:
       reddit:
```
15. Пересоздадим сервисы, в списке endpoint-ов Prometheus- должен появится endpoint-mongod.
16. Ссылка на docker-hub https://hub.docker.com/u/rastamalik/


## Homework-20
1. Создадим новый проект **example2**, добавим новый **remote**:
```
 git checkout -b docker-7
 git remote add gitlab2 http://<your-vm-ip>/homework/example2.git
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
  script:
    - echo 'Testing 1'


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
```
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


## Homework-17
1. Запустим контейнер с использованием none-драйвера. В качестве образа используем **joffotron/docker-net-tools**.
```
docker run --network none --rm -d --name net_test joffotron/docker-net-tools -c "sleep 100"
```
2. Запустим контейнер в сетевом пространстве docker-хоста:
```
docker run --network host --rm -d --name net_test joffotron/docker-net-tools -c "sleep 100"
```
3. Создадим **bridge-сеть** в docker:
```
docker network create reddit --driver bridge
```
Запустим наш проект **reddit** с использованием **bridge-сети**:
```
docker run -d --network=reddit mongo:latest
docker run -d --network=reddit rastamalik/post:1.0
docker run -d --network=reddit rastamalik/comment:1.0
docker run -d --network=reddit -p 9292:9292 rastamalik/ui:1.0
```
3. Присвоим контейнерам сетевые алисы:
```
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post rastamalik/post:1.0
docker run -d --network=reddit --network-alias=comment rastamalik/comment:1.0
docker run -d --network=reddit -p 9292:9292 rastamalik/ui:1.0
```
4. Создадим **docker-сети**:
```
docker network create back_net —subnet=10.0.2.0/24
docker network create front_net --subnet=10.0.1.0/24
```
Запустим контейнеры:
```
docker run -d --network=front_net -p 9292:9292 --name ui rastamalik/ui:1.0
docker run -d --network=back_net --name comment rastamalik/comment:1.0
docker run -d --network=back_net --name post rastamalik/post:1.0
docker run -d --network=back_net --name mongo_db --network-alias=post_db --network-alias=comment_db mongo:latest
```
Подключим контейнеры ко второй сети:
```
docker network connect front_net post
docker network connect front_net comment
```
5. Установка docker-compose:
```
pip install docker-compose
```
6. В директории с проеком **reddit-microservices**  создадим файл **docker-compose.yml**:
```
version: '3.3'
services:
  post_db:
    image: mongo:3.2
    volumes:
      - post_db:/data/db
    networks:
      - reddit
  ui:
    build: ./ui
    image: ${USERNAME}/ui:1.0
    ports:
      - 9292:9292/tcp
    networks:
      - reddit
  post:
    build: ./post-py
    image: ${USERNAME}/post:1.0
    networks:
      - reddit
  comment:
    build: ./comment
    image: ${USERNAME}/comment:1.0
    networks:
      - reddit

volumes:
  post_db:

networks:
  reddit:
  ```
  Экспортируем переменную **USERNAME** ```export USERNAME=<rastamalik``` и выолним:
  ```
  docker-compose up -d
  docker-compose ps
```
7. Изменим **docker-compose** под кейс с множеством сетей, сетевых алиасов и параметризируем с помощью переменных окружений:
```
version: '3.3'
services:
  post_db:
    image: mongo:3.2
    volumes:
      - post_db:/data/db
    networks:
       back_net:
           aliases:
              - post_db
              - comment_db
  ui:
    build: ./ui
    image: ${USERNAME}/ui:${VERSION}
    ports:
      - ${UI_PORTS}:${UI_PORTS}/tcp
    networks:
      front_net:

  post:
    build: ./post-py
    image: ${USERNAME}/post:${VERSION}
    networks:
       front_net:
       back_net:
            aliases:
              - post
  comment:
    build: ./comment
    image: ${USERNAME}/comment:${VERSION}
    networks:
        front_net:
        back_net:
            aliases:
              - comment

volumes:
  post_db:

networks:
   front_net:
   back_net:
   ```
  Параметризованные параметры запишем в отдельный файл c расширением **.env**

  8. Изменить базовое имя проекта можно с помощью опции **-p**
  ```
  docker-compose -p project1 up
  ```
  9. Создал файл **docker-compose.override.yml** при помощи которого запускаем **puma** для руби приложений в дебаг режиме с двумя воркерами (флаги --debug и -w 2):
```
  version: '3.3'
services:
  ui:
    command: "puma --debug -w 2"
```


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
