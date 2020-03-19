FROM centos:7

# Add Tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

## SSH
RUN yum -y install openssh-server mysql

## Configure user
RUN useradd remote_user && \
  echo "1234" | passwd remote_user --stdin && \
  mkdir /home/remote_user/.ssh && \
  chmod 700 /home/remote_user/.ssh

# Configure keys
COPY remote-key.pub /home/remote_user/.ssh/authorized_keys

# Copy the start
COPY start.sh /start.sh

# Control the keys
RUN chown remote_user:remote_user -R /home/remote_user/.ssh && \
  chmod 600 /home/remote_user/.ssh/authorized_keys && \
  chmod 755 /start.sh

# Install pip
RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
  python get-pip.py && \
  pip install awscli --upgrade

# Create the keys
RUN /usr/sbin/sshd-keygen


# Entrypoint tini
ENTRYPOINT ["/tini", "--"]

# remote the nologin and start the ssh
CMD /start.sh
