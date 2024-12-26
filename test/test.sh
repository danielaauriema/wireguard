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
bash_wait_for "[ -f /data/wireguard/conf/client_02/${WG__NAME}.conf ]" 60
cp "/data/wireguard/conf/client_02/${WG__NAME}.conf" "/etc/wireguard/${WG__NAME}.conf"

bash_test_header "wg_test :: wait for connection"
bash_wait_for "wg-quick up ${WG__NAME}"

bash_test_header "wg_test :: ping itself"
bash_wait_for "ping -q -c 1 172.16.21.102"

bash_test_header "wg_test :: ping server"
bash_wait_for "ping -q -c 1 172.16.21.1" 60

bash_test_header "wg_test :: ping client_01"
bash_wait_for "ping -q -c 1 172.16.21.101"

bash_test_header "wg_test :: check DNS server"
dig +noall +answer @172.16.21.1 "${SERVER__BASE_DOMAIN}" | grep 172.16.21.1

bash_test_header "wg_test :: check subdomain"
dig +noall +answer @172.16.21.1 "any.${SERVER__BASE_DOMAIN}" | grep 172.16.21.1

bash_test_header "wg_test :: check custom subdomain"
dig +noall +answer @172.16.21.1 "custom.${SERVER__BASE_DOMAIN}" | grep "${SERVER__NETWORK_PREFIX}.99"

bash_test_header "wg_test :: all tests has finished successfully!!"