pip3 install j2cli yq 
apt install jq --yes
MINION_TEMPLATE=$(salt_host_data_iface=$3 j2 minion.tpl |yq .  |tr  "\n" " ")
echo "$MINION_TEMPLATE"
sh bootstrap-salt.sh -D -x python3 -F -i "$1" -A "$2" -j "$MINION_TEMPLATE"