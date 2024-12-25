#FROM debian:bookworm-slim
#
#RUN apt update && \
#    apt install -y vim curl wireguard iproute2 iputils-ping openresolv bind9 dnsutils
#
## Ansible Install
#RUN apt install -y wget gpg python3 && \
#    wget -O- "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" | gpg --batch --yes --dearmour -o /usr/share/keyrings/ansible-archive-keyring.gpg && \
#    echo "deb [signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu jammy main" | tee /etc/apt/sources.list.d/ansible.list && \
#    apt update && \
#    apt install -y ansible

FROM auriema/wireguard:b1

ENV WG__VPN_NAME="wg_vpn"
ENV WG__SERVER_ADDR="wg_server"
ENV WG__SERVER_PORT="51820"

## Set Gitea variables
#ENV GITEA__security__INSTALL_LOCK="true"
#ENV GITEA__service__DISABLE_REGISTRATION="true"

ADD wireguard /opt/wireguard
RUN chmod -R +rx /opt/wireguard
#WORKDIR /opt/startup
#

EXPOSE 53/udp
EXPOSE 51820/udp

ENTRYPOINT [ "/opt/wireguard/entrypoint" ]
CMD []
