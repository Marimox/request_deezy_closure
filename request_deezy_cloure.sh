#!/bin/bash

##################################################
#
# request_deezy_closure
#
# arguments:
#   $1: channel point
#
##################################################

echo "========================================"

echo "[INFO ] Get Earn Info"

res_info=$(curl -s -X GET https://api.deezy.io/v1/earn/info \
                   -H "content-type: application/json")

earn_ppm=$(echo ${res_info} | jq -r .close_channel_earn_ppm)

echo "[INFO ] current_earn_ppm   =[${earn_ppm}]"

echo "========================================"

echo "[INFO ] exec lncli signmessage"
res_signature=$(docker exec lightning_lnd_1 lncli signmessage "close $1")

signature=$(echo ${res_signature} | jq -r .signature)

echo "[INFO ] channel_point      =[$1]"
echo "[INFO ] signature          =[${signature}]"

echo "========================================"

echo "[INFO ] Request Earn by Closing Channel"
res_closechannel=$(curl -s -X POST https://api.deezy.io/v1/earn/closechannel \
                           -H "content-type: application/json" \
                           -d '{"channel_point":"'$1'","signature":"'${signature}'"}')

payout_ppm=$(echo ${res_closechannel} | jq -r .payout_ppm)
payout_payment_hash=$(echo ${res_closechannel} | jq -r .payout_payment_hash)
status=$(echo ${res_closechannel} | jq -r .status)

echo "[INFO ] payout_ppm         =[${payout_ppm}]"
echo "[INFO ] payout_payment_hash=[${payout_payment_hash}]"
echo "[INFO ] status             =[${status}]"

echo "========================================"

