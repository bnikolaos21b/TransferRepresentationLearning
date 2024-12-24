FROM jenkins/jenkins:lts

USER root

# Εγκατάσταση απαραίτητων εργαλείων
RUN apt-get update && apt-get install -y \
    docker.io \
    python3 \
    python3-pip \
    python3-venv \
    git \
    curl \
    wget \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Προσθήκη του Jenkins user στο Docker group
RUN usermod -aG docker jenkins

# Εγκατάσταση Node.js 14.x από επίσημο tarball
RUN curl -fsSL https://nodejs.org/dist/v14.21.3/node-v14.21.3-linux-x64.tar.xz | tar -xJ -C /usr/local --strip-components=1 && \
    ln -s /usr/local/bin/node /usr/bin/node && \
    ln -s /usr/local/bin/npm /usr/bin/npm && \
    node -v && npm -v

# Εγκατάσταση global npm packages
RUN npm install -g eslint

# Δημιουργία εικονικού περιβάλλοντος
RUN python3 -m venv /opt/venv

# Ενεργοποίηση του εικονικού περιβάλλοντος και εγκατάσταση Python πακέτων
RUN /opt/venv/bin/pip install --upgrade pip && \
    /opt/venv/bin/pip install bandit sqlmap pylint

# Εγκατάσταση SonarScanner
RUN wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.7.0.2747-linux.zip && \
    unzip sonar-scanner-cli-4.7.0.2747-linux.zip -d /opt && \
    rm sonar-scanner-cli-4.7.0.2747-linux.zip

# Προσθήκη SonarScanner και του εικονικού περιβάλλοντος στο PATH
ENV PATH="/opt/sonar-scanner-4.7.0.2747-linux/bin:/opt/venv/bin:${PATH}"

USER jenkins

