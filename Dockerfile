FROM ubuntu:16.04
RUN apt-get update
RUN apt-get install -y mongodb-server ruby-full ruby-dev build-essential git
RUN gem install bundler
RUN git clone https://github.com/express42/reddit.git  && rm -rf ./reddit/.git
RUN cd /reddit && bundle install