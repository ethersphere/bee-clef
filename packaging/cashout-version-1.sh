#!/usr/bin/env bash

###
 # @Author: your name
 # @Date: 2021-05-19 10:35:20
 # @LastEditTime: 2021-05-19 10:36:19
 # @LastEditors: Please set LastEditors
 # @Description: In User Settings Edit
 # @FilePath: /bee-clef/packaging/cashout-version-1.sh
###


[ -z ${DEBUG_API+x} ] && DEBUG_API=http://localhost:1635/
[ -z ${MIN_AMOUNT+x} ] && MIN_AMOUNT=10000000000000000

function getPeers() {
  curl -s "$DEBUG_API/chequebook/cheque" | jq -r '.lastcheques | .[].peer'
}

function getCumulativePayout() {
  local peer=$1
  local cumulativePayout=$(curl -s "$DEBUG_API/chequebook/cheque/$peer" | jq '.lastreceived.payout')
  if [ "$cumulativePayout"x == null ]
  then
    echo 0
  else
    echo $cumulativePayout
  fi
}

function getLastCashedPayout() {
  local peer=$1
  local cashout=$(curl -s "$DEBUG_API/chequebook/cashout/$peer" | jq '.cumulativePayout')
  if [ "$cashout"x == null ]
  then
    echo 0
  else
    echo $cashout
  fi
}

function getUncashedAmount() {
  local peer=$1
  local cumulativePayout=$(getCumulativePayout $peer)
  if [ "$cumulativePayout"x == 0 ]
  then
    echo 0
    return
  fi

  cashedPayout=$(getLastCashedPayout $peer)
  let uncashedAmount=$((cumulativePayout-cashedPayout))
  echo $uncashedAmount
}

function cashout() {
  local peer=$1
  local response=$(curl -s -XPOST "$DEBUG_API/chequebook/cashout/$peer")
  local txHash=$(echo "$response" | jq -r .transactionHash)
  if [ "$txHash" == "null" ]
  then
    echo could not cash out cheque for $peer: $(echo "$response" | jq -r .code,.message)
    return
  fi

  echo cashing out cheque for $peer in transaction $txHash >&2

  result="$(curl -s $DEBUG_API/chequebook/cashout/$peer | jq .result)"
  while [ "$result" == "null" ]
  do
    sleep 5
    result=$(curl -s $DEBUG_API/chequebook/cashout/$peer | jq .result)
  done
}

function cashoutAll() {
  local minAmount=$1
  for peer in $(getPeers)
  do
    local uncashedAmount=$(getUncashedAmount $peer)
    if (( "$uncashedAmount" > $minAmount ))
    then
      echo "uncashed cheque for $peer ($uncashedAmount uncashed)" >&2
      cashout $peer
    fi
  done
}

function listAllUncashed() {
  for peer in $(getPeers)
  do
    local uncashedAmount=$(getUncashedAmount $peer)
    if (( "$uncashedAmount" > 0 ))
    then
      echo $peer $uncashedAmount
    fi
  done
}

case $1 in
cashout)
  cashout $2
  ;;
cashout-all)
  cashoutAll $MIN_AMOUNT
  ;;
list-uncashed|*)
  listAllUncashed
  ;;
esac