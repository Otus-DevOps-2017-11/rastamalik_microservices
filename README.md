# rastamalik_microservices
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
