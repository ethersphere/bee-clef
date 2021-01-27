#!/bin/sh

ACTION="${1:-run}"
CHAINID="${CLEF_CHAINID:-12345}"
DATA=/app/data

init() {
    parse_json() { echo $1|sed -e 's/[{}]/''/g'|sed -e 's/", "/'\",\"'/g'|sed -e 's/" ,"/'\",\"'/g'|sed -e 's/" , "/'\",\"'/g'|sed -e 's/","/'\"---SEPERATOR---\"'/g'|awk -F=':' -v RS='---SEPERATOR---' "\$1~/\"$2\"/ {print}"|sed -e "s/\"$2\"://"|tr -d "\n\t"|sed -e 's/\\"/"/g'|sed -e 's/\\\\/\\/g'|sed -e 's/^[ \t]*//g'|sed -e 's/^"//' -e 's/"$//' ; }
    if [ ! -f "$DATA"/password ]; then
        < /dev/urandom tr -dc _A-Z-a-z-0-9 2> /dev/null | head -c32 > "$DATA"/password
    fi
    SECRET=$(cat "$DATA"/password)
    /usr/local/bin/clef --configdir "$DATA" --stdio-ui init >/dev/null 2>&1 << EOF
$SECRET
$SECRET
EOF
    if [ "$(ls -A "$DATA"/keystore 2> /dev/null)" = "" ]; then
        /usr/local/bin/clef --keystore "$DATA"/keystore --stdio-ui newaccount >/dev/null 2>&1 << EOF
$SECRET
EOF
    fi
    /usr/local/bin/clef --keystore "$DATA"/keystore --configdir "$DATA" --stdio-ui setpw 0x"$(parse_json "$(cat "$DATA"/keystore/*)" address)" >/dev/null 2>&1 << EOF
$SECRET
$SECRET
$SECRET
EOF
    /usr/local/bin/clef --keystore "$DATA"/keystore --configdir "$DATA" --stdio-ui attest "$(sha256sum /app/config/rules.js | cut -d' ' -f1 | tr -d '\n')" >/dev/null 2>&1 << EOF
$SECRET
EOF
}

run() {
    SECRET=$(cat "$DATA"/password)
( sleep 1; cat << EOF
{ "jsonrpc": "2.0", "id":1, "result": { "text":"$SECRET" } }
EOF
) | /usr/local/bin/clef --stdio-ui --keystore "$DATA"/keystore --configdir "$DATA" --chainid "$CHAINID" --http --http.addr 0.0.0.0 --http.port 8550 --http.vhosts * --rules /app/config/rules.js --nousb --ipcdisable --4bytedb-custom /app/config/4byte.json --pcscdpath "" --auditlog "" --loglevel 3
}

full() {
    if [ ! -f "$DATA"/masterseed.json ]; then
        init
    fi
    run
}

$ACTION
