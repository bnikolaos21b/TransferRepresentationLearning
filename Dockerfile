FROM jenkins/jenkins:lts

USER root

# Εγκατάσταση Python και pip
RUN apt-get update && apt-get install -y python3 python3-pip

# Εγκατάσταση Bandit με bypass
RUN pip install bandit --break-system-packages
RUN pip install sqlmap --break-system-packages

USER jenkins

