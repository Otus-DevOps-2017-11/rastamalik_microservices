USER_NAME ?= rastamalik
PASSWORD ?= xela4321
VERSION ?= latest
DOCKER_PATH ?=  ~/rastamalik_microservices/src
DOCKER_PROM ?= ~/rastamalik_microservices/monitoring/prometheus
DOCKER_ALERT ?= ~/rastamalik_microservices/monitoring/alertmanager
COMPOSE_PATH ?= ~/rastamalik_microservices/docker
dirs_ui := ui
dirs_post := post-py
dirs_comment := comment
build:
	 cd $(DOCKER_PATH)/$(dirs_ui); bash docker_build.sh;
	 cd $(DOCKER_PATH)/$(dirs_post); bash docker_build.sh;
	 cd $(DOCKER_PATH)/$(dirs_comment); bash docker_build.sh;
	 cd $(DOCKER_PROM); docker build -t $(USER_NAME)/prometheus .;
	 cd $(DOCKER_ALERT); docker build -t $(USER_NAME)/alertmanager .;
	 docker login -u $(USER_NAME) -p $(PASSWORD);
	 docker push $(USER_NAME)/ui;
	 docker push $(USER_NAME)/comment;
	 docker push $(USER_NAME)/post;
	 docker push $(USER_NAME)/prometheus;
	 docker push $(USER_NAME)/alertmanager;
