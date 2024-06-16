#!/bin/bash

export TOKEN="ya29.a0AfB_byA0aRrZAVQhNaJsxGdM-C3h-fq0IDTJJA6GWDh5faxB2Fk69hx1nD9X_fKMv1l-B5J2mAIwzKhjDIzu6OMqSZTnumzY4hFc8WvYWOyEUWPQK16npP94DMi22QviNCNTiyiANxV_xjKPKhpdWZKXPjzZW34TvPC5Id-h6zHu5v628q56NN-5Cp6vKWFU51LsJPXKEX7Mv8bhqUTh_jfyRzs_7gDUOZRPrYKk2AWv_AKMagsYfT4IxJMPnEyMFD2yo6yJmAXhmwR-28ve4Lpe-YfnYAnW5CY8n7_K2-GsrBd79mCDvyFhIN736k1Fbv_LLbhHSTGmK9-CFqgMUO8i3gWJe0DvdFJSBWdc38jSows2olpkmFMTeuS_sHBzqsvN7Cvt0iMI8ntXv50_tZq29IW2GUK9aCgYKAQMSARESFQHGX2Miez25SAtXaiconZsXNFN6_A0423"
export ORG_NAME="phoenix-apigee-poc"
export REQ_BASEPATH="/corpapi/v1/eSign/proxy"

#call to get list of api's
export RES1=$(curl -s 'https://apigee.googleapis.com/v1/organizations/'${ORG_NAME}'/apis/' \
        --header 'Authorization: Bearer '${TOKEN}'')
export API_LIST=$(echo ${RES1} | jq -r ".proxies[].name")

while IFS= read -r line; do
    # call to get specific api details which contains list of revisions
    export RES2=$(curl -s 'https://apigee.googleapis.com/v1/organizations/'${ORG_NAME}'/apis/'${line}'' \
        --header 'Authorization: Bearer '${TOKEN}'')
    export REVISIONS=$(echo ${RES2} | jq -r ".revision")
    export REV_VALUES=$(echo "$REVISIONS" | jq -r '.[]')

    MAX_VALUE=0
    #Loop to get lastest revision bundle
    for value in $REV_VALUES; do
      if [ "$value" -gt "$MAX_VALUE" ]; then
        MAX_VALUE=$value
      fi
    done

    #call to get api basepath
    export BASEPATH_RES=$(curl -s 'https://apigee.googleapis.com/v1/organizations/'${ORG_NAME}'/apis/'${line}'/revisions/'${MAX_VALUE}'' \
        --header 'Authorization: Bearer '${TOKEN}'')
    export BASEPATH=$(echo ${BASEPATH_RES} | jq -r ".basepaths[0]")

    #checking specific basepath is same as required basepath or not
    if [ $BASEPATH = $REQ_BASEPATH ] ; then
            echo "$line"
            exit 0
    fi

done <<< "$API_LIST"