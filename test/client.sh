#!/bin/bash
set -e

if [ ! -f "./bash-test.sh" ]; then
  curl -s "https://raw.githubusercontent.com/danielaauriema/bash-tools/master/lib/bash-test.sh" > "/opt/test/bash-test.sh"
fi
if [ ! -f "./bash-wait.sh" ]; then
  curl -s "https://raw.githubusercontent.com/danielaauriema/bash-tools/master/lib/bash-wait.sh" > "/opt/test/bash-wait.sh"
fi

. /opt/test/bash-wait.sh
. /opt/test/bash-test.sh

bash_test_header "wg_client :: wait for config file"
bash_wait_for "stat -c %n /data/wireguard/conf/client_01/${WG__NAME}.conf > /dev/null" 60
cp "/data/wireguard/conf/client_01/${WG__NAME}.conf" "/etc/wireguard/${WG__NAME}.conf"

bash_test_header "wg_client :: wait for connection"
bash_wait_for "wg-quick up ${WG__NAME}"

bash_test_header "wg_client :: ping itself"
bash_wait_for "ping -q -c 1 172.16.21.101"

bash_test_header "wg_client :: ping server"
bash_wait_for "ping -q -c 1 172.16.21.1" 60

bash_test_header "wg_client :: all tests has finished successfully!!"