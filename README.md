# Description

Docker image with all the commonly used tools to build Java applications on Jenkins slaves.

We have decided to bundle many tools in the same image to cover as many Java use cases as possible. In a second iteration, we plan to offer granularity in the tools installed on the image, maybe using a `Dockerfile` generator.

# Supported tags and respective `Dockerfile` links

-   [`latest` (*latest/Dockerfile*)](https://github.com/ajurasz/java-build-tools-dockerfile/blob/master/Dockerfile)
-   [`0.0.1` (*0.0.1/Dockerfile*)](https://github.com/ajurasz/java-build-tools-dockerfile/blob/0.0.1/Dockerfile)

# Version latest
-   OS: Ubuntu 18.04
-   Common tools: openssh-client, unzip, wget, curl, git, jq, rsync
-   Ant 1.10.7
-   Firefox at `/usr/bin/firefox`: 68.1.0esr
-   Firefox Geckodriver at `/usr/bin/geckodriver`: v0.25.0
-   gcc (latest): 5.4.0
-   Grunt CLI: 1.3.1
-   Gulp: 4.0.0
-   Java: OpenJDK 11 (latest): 11.0.6
-   JMeter (5.1.1) located in `/opt/jmeter/`
-   Make (latest): 4.1
-   Maven located in `/usr/share/maven/`: 3.6.2
-   MySQL Client: Ver 14.14 Distrib 5.7.27
-   Node.js at `/usr/bin/nodejs`: 10.16.3
-   Npm at `/usr/bin/npm`: 6.9.0
-   Python/2.7.17
-   Selenium at `/opt/selenium/selenium-server-standalone.jar`: 3.141.59
-   XVFB: 2:1.18.4
-   Docker: 18.06.2-ce
-   Docker Compose: 1.22.0
-   Gradle: 5.6.2

# Version 0.0.1
-   OS: Ubuntu 18.04
-   Common tools: openssh-client, unzip, wget, curl, git, jq, rsync
-   Ant 1.10.7
-   Firefox at `/usr/bin/firefox`: 68.1.0esr
-   Firefox Geckodriver at `/usr/bin/geckodriver`: v0.25.0
-   gcc (latest): 5.4.0
-   Grunt CLI: 1.3.1
-   Gulp: 4.0.0
-   Java: OpenJDK 11 (latest): 11.0.6
-   JMeter (5.1.1) located in `/opt/jmeter/`
-   Make (latest): 4.1
-   Maven located in `/usr/share/maven/`: 3.6.2
-   MySQL Client: Ver 14.14 Distrib 5.7.27
-   Node.js at `/usr/bin/nodejs`: 10.16.3
-   Npm at `/usr/bin/npm`: 6.9.0
-   Python/2.7.17
-   Selenium at `/opt/selenium/selenium-server-standalone.jar`: 3.141.59
-   XVFB: 2:1.18.4
-   Docker: 18.06.2-ce
-   Docker Compose: 1.22.0
-   Gradle: 5.6.2

# License

The cloudbees/java-build-tools image is licensed under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0), and this repository is too:

```
Copyright 2015 CloudBees, Inc


Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
