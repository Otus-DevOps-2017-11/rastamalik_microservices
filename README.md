# rastamalik_microservices
## Homework-17
1. Запустим контейнер с использованием none-драйвера. В качестве образа используем **joffotron/docker-net-tools**.
```docker run --network none --rm -d --name net_test joffotron/docker-net-tools -c "sleep 100"
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
    




  
