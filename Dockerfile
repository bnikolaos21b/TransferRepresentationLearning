FROM jenkins/jenkins:lts

USER root

# Εγκατάσταση απαραίτητων εργαλείων
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    curl \
    wget \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Εγκατάσταση Node.js 14.x από επίσημο tarball
RUN curl -fsSL https://nodejs.org/dist/v14.21.3/node-v14.21.3-linux-x64.tar.xz | tar -xJ -C /usr/local --strip-components=1 && \
    ln -s /usr/local/bin/node /usr/bin/node && \
    ln -s /usr/local/bin/npm /usr/bin/npm && \
    node -v && npm -v

# Εγκατάσταση global npm packages
RUN npm install -g eslint

# Εγκατάσταση Python εργαλεία
RUN pip3 install bandit sqlmap pylint

# Εγκατάσταση SonarScanner
RUN wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.7.0.2747-linux.zip && \
    unzip sonar-scanner-cli-4.7.0.2747-linux.zip -d /opt && \
    rm sonar-scanner-cli-4.7.0.2747-linux.zip

ENV PATH="/opt/sonar-scanner-4.7.0.2747-linux/bin:${PATH}"

USER jenkins

