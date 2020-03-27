FROM adoptopenjdk/openjdk11:jdk-11.0.6_10-ubuntu
LABEL name="Java Build Tools" \
      maintainer="Cyrille Le Clerc <cleclerc@cloudbees.com>" \
      license="Apache-2.0" \
      version="latest" \
      summary="Convenient Docker image to build Java applications." \
      description="Convenient Docker image to build Java applications."


#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#################################################
# Inspired by
# https://github.com/SeleniumHQ/docker-selenium/blob/master/Base/Dockerfile
#################################################


#================================================
# Customize sources for apt-get
#================================================
RUN DISTRIB_CODENAME=$(cat /etc/*release* | grep DISTRIB_CODENAME | cut -f2 -d'=') \
    && echo "deb http://archive.ubuntu.com/ubuntu ${DISTRIB_CODENAME} main universe\n" > /etc/apt/sources.list \
    && echo "deb http://archive.ubuntu.com/ubuntu ${DISTRIB_CODENAME}-updates main universe\n" >> /etc/apt/sources.list \
    && echo "deb http://security.ubuntu.com/ubuntu ${DISTRIB_CODENAME}-security main universe\n" >> /etc/apt/sources.list

RUN apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install software-properties-common \
  && add-apt-repository -y ppa:git-core/ppa

#========================
# Miscellaneous packages
# iproute which is surprisingly not available in ubuntu:15.04 but is available in ubuntu:latest
# OpenJDK8
# rlwrap is for azure-cli
# groff is for aws-cli
# tree is convenient for troubleshooting builds
#========================
RUN apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install \
    openssh-client ssh-askpass\
    ca-certificates \
    tar zip unzip \
    wget curl \
    git \
    build-essential \
    less nano tree \
    jq \
    python python-pip groff \
    rlwrap \
    rsync \
  && rm -rf /var/lib/apt/lists/* \

# workaround https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=775775
RUN [ -f "/etc/ssl/certs/java/cacerts" ] || /var/lib/dpkg/info/ca-certificates-java.postinst configure

# workaround "You are using pip version 8.1.1, however version 9.0.1 is available."
RUN pip install --upgrade pip setuptools

RUN pip install yq

#==========
# Docker
#==========
ENV DOCKER_VERSION 18.06.2

RUN curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_VERSION-ce.tgz | tar xzf - -C /usr/share \
  && ln -s /usr/share/docker/docker /usr/bin/docker

#==========
# Docker Compose
#==========  
ENV DOCKER_COMPOSE_VERSION 1.22.0

RUN curl -fsSL --output /usr/share/docker-compose  https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` \
  && chmod +x /usr/share/docker-compose \
  && ln -s /usr/share/docker-compose /usr/bin/docker-compose

#==========
# Maven
#==========
ENV MAVEN_VERSION 3.6.2

RUN curl -fsSL http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven

#==========
# Ant
#==========

ENV ANT_VERSION 1.10.7

RUN curl -fsSL https://www.apache.org/dist/ant/binaries/apache-ant-$ANT_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-ant-$ANT_VERSION /usr/share/ant \
  && ln -s /usr/share/ant/bin/ant /usr/bin/ant

ENV ANT_HOME /usr/share/ant

#==========
# Gradle
#==========

ENV GRADLE_VERSION 5.6.2

RUN curl -fsSL --output /usr/share/gradle.zip https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip \
  && unzip /usr/share/gradle.zip -d /usr/share/ \
  && mv /usr/share/gradle-$GRADLE_VERSION /usr/share/gradle \
  && ln -s /usr/share/gradle/bin/gradle /usr/bin/gradle \
  && rm -rf /usr/share/gradle.zip

ENV GRADLE_HOME /usr/share/gradle

#==========
# Selenium
#==========

ENV SELENIUM_MAJOR_VERSION 3.141
ENV SELENIUM_VERSION 3.141.59
RUN  mkdir -p /opt/selenium \
  && wget --no-verbose http://selenium-release.storage.googleapis.com/$SELENIUM_MAJOR_VERSION/selenium-server-standalone-$SELENIUM_VERSION.jar -O /opt/selenium/selenium-server-standalone.jar

RUN pip install -U selenium

# https://github.com/SeleniumHQ/docker-selenium/blob/master/StandaloneFirefox/Dockerfile

ENV SCREEN_WIDTH 1360
ENV SCREEN_HEIGHT 1020
ENV SCREEN_DEPTH 24
ENV DISPLAY :99.0

COPY entry_point.sh /opt/bin/entry_point.sh
COPY functions.sh /opt/bin/functions.sh
RUN chmod +x /opt/bin/entry_point.sh \
  && chmod +x /opt/bin/functions.sh

#========================================
# Add normal user with passwordless sudo
#========================================
RUN useradd jenkins --shell /bin/bash --create-home \
  && usermod -a -G sudo jenkins \
  && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && echo 'jenkins:secret' | chpasswd

#=====
# XVFB
#=====
RUN apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install \
    xvfb \
  && rm -rf /var/lib/apt/lists/*

#=========
# Firefox
#=========
ARG FIREFOX_VERSION=68.1.0esr

# don't install firefox with apt-get because there are some problems,
# install the binaries downloaded from mozilla
# see https://github.com/SeleniumHQ/docker-selenium/blob/3.0.1-fermium/NodeFirefox/Dockerfile#L13
# workaround "D-Bus library appears to be incorrectly set up; failed to read machine uuid"
# run "dbus-uuidgen > /var/lib/dbus/machine-id"

RUN apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install firefox dbus \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
  && wget --no-verbose -O /tmp/firefox.tar.bz2 https://download-installer.cdn.mozilla.net/pub/firefox/releases/$FIREFOX_VERSION/linux-x86_64/en-US/firefox-$FIREFOX_VERSION.tar.bz2 \
  && apt-get -y purge firefox \
  && rm -rf /opt/firefox \
  && tar -C /opt -xjf /tmp/firefox.tar.bz2 \
  && rm /tmp/firefox.tar.bz2 \
  && mv /opt/firefox /opt/firefox-$FIREFOX_VERSION \
  && ln -fs /opt/firefox-$FIREFOX_VERSION/firefox /usr/bin/firefox

RUN dbus-uuidgen > /var/lib/dbus/machine-id

#======================
# Firefox GECKO DRIVER
#======================

ARG GECKO_DRIVER_VERSION=v0.25.0
RUN wget -O - "https://github.com/mozilla/geckodriver/releases/download/$GECKO_DRIVER_VERSION/geckodriver-$GECKO_DRIVER_VERSION-linux64.tar.gz" \
      | tar -xz -C /usr/bin

#====================================
# NODE JS
#====================================
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 10.16.3

RUN mkdir -p $NVM_DIR \
  && curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash \
  && . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION} \
  && . "$NVM_DIR/nvm.sh" &&  nvm use v${NODE_VERSION} \
  && . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

#====================================
# JMETER
#====================================
RUN mkdir /opt/jmeter \
      && wget -O - "https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-5.1.1.tgz" \
      | tar -xz --strip=1 -C /opt/jmeter

#====================================
# MYSQL CLIENT
#====================================
RUN apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install \
    mysql-client \
  && rm -rf /var/lib/apt/lists/*

USER jenkins

# for dev purpose
# USER root

ENTRYPOINT ["/opt/bin/entry_point.sh"]

EXPOSE 4444
