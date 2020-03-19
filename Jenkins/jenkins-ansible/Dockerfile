# Jenkins
FROM jenkins/jenkins

# need to run everything with root
USER root

# Install pip
RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
  python get-pip.py && \
  pip install ansible --upgrade

# Back the default user
USER jenkins
