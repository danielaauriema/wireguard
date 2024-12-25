FROM debian:bookworm-slim

RUN apt update && \
    apt install -y vim curl wireguard iproute2 iputils-ping openresolv bind9 dnsutils

# Ansible Install
RUN apt install -y wget gpg python3 && \
    wget -O- "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" | gpg --batch --yes --dearmour -o /usr/share/keyrings/ansible-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu jammy main" | tee /etc/apt/sources.list.d/ansible.list && \
    apt update && \
    apt install -y ansible


#    mkdir -p /opt/lib && \
#    curl -s https://raw.githubusercontent.com/danielaauriema/bash-tools/master/lib/bash-wait.sh > /opt/lib/bash-wait.sh


#RUN mkdir -p /opt/lib && \
#    curl -s https://raw.githubusercontent.com/danielaauriema/bash-tools/master/lib/bash-wait.sh > /opt/lib/bash-wait.sh
#
## Set Gitea admin user
#ENV GITEA__ADMIN_USERNAME="gitea"
#ENV GITEA__ADMIN_PASSWORD="password"
#ENV GITEA__ADMIN_EMAIL="gitea@gitea.local"
#
## Set LDAP connection
#ENV LDAP__PROTOCOL="unencrypted"
#ENV LDAP__HOST="openldap"
#ENV LDAP__PORT="389"
#ENV LDAP__BASE_DN="dc=gitea,dc=local"
#ENV LDAP__SEARCH_BASE="ou=users,${LDAP__BASE_DN}"
#ENV LDAP__BIND_DN="cn=bind,${LDAP__BASE_DN}"
#ENV LDAP__BIND_PASSWORD="password"
#
## Set Gitea variables
#ENV GITEA__security__INSTALL_LOCK="true"
#ENV GITEA__service__DISABLE_REGISTRATION="true"
#
#ADD startup /opt/startup
#RUN chmod -R +rx /opt/startup
#WORKDIR /opt/startup
#
#ENTRYPOINT [ "/opt/wireguard/entrypoint" ]
#CMD []
