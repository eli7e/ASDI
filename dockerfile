FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Brussels

# Use bash as default shell
SHELL ["/bin/bash", "-c"]

# Set timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update and install base dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    python3-dev \
    libkrb5-dev \
    libssl-dev \
    libffi-dev \
    build-essential \
    curl \
    git \
    unzip \
    python3-pip \
    python3-venv \
    krb5-user \
    sshpass \
    openssh-client \
    openssh-server \
    apt-utils \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip safely
RUN python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel

# Install Python packages
RUN pip3 install --no-cache-dir \
    ansible \
    pywinrm[kerberos] \
    pykerberos \
    pyVim \
    PyVmomi \
    git+https://github.com/vmware/vsphere-automation-sdk-python.git

# Install Ansible Galaxy collection for VMware
RUN ansible-galaxy collection install community.vmware

# Create ansible user
RUN useradd -m ansible

# Copy Kerberos config
COPY krb5.conf /etc/krb5.conf
RUN chown root:root /etc/krb5.conf

# Set working directory
WORKDIR /etc/ansible/playbooks

# Copy Ansible configurations
COPY ./group_vars /etc/ansible/playbooks/group_vars
COPY DeployVMtoolsSilently.yml /etc/ansible/playbooks/DeployVMtoolsSilently.yml
COPY VoltPass.txt /etc/ansible/VoltPass.txt
COPY secrets.yml /etc/ansible/playbooks/secrets.yml
COPY ramz.yml /etc/ansible/playbooks/ramz.yml
COPY ansible.cfg /etc/ansible/ansible.cfg   # <---- no need to care where Ansible runs from — it'll always pick up this config.

CMD ["/bin/bash"]



