# rastamalik_microservices

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
