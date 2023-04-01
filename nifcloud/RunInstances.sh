#!/bin/bash
# Define func for urlencode
function urlencode {
    echo "$1" | nkf -WwMQ | sed 's/=$//g' | tr = % | tr -d '\n'
}

# KEYs
NIFCLOUD_ACCESS_KEY_ID=${NIFCLOUD_ACCESS_KEY_ID}
NIFCLOUD_SECRET_ACCESS_KEY=${NIFCLOUD_SECRET_ACCESS_KEY}

# Request Info
request_method=POST
request_endpoint=jp-west-1.computing.api.nifcloud.com
request_path=/api/
request_action=RunInstances
request_date=$(date '+%Y-%m-%dT%H%%3A%M%%3A%SZ')

# Create request string
request_string=$({
    echo -n "AccessKeyId=${NIFCLOUD_ACCESS_KEY_ID}"
    echo -n "&AccountingType=1"
    echo -n "&Action=RunInstances"
    echo -n "&Admin="
    echo -n "&Agreement=true"
    echo -n "&Description="
    echo -n "&DisableApiTermination=false"
    echo -n "&ImageId=283"
    echo -n "&InstanceId=w11002wk03"
    echo -n "&InstanceType=e-medium"
    echo -n "&KeyName=deployerkey"
    echo -n "&NetworkInterface.1.IpAddress="
    echo -n "&NetworkInterface.1.NetworkId=net-COMMON_GLOBAL"
    echo -n "&NetworkInterface.1.NetworkName="
    echo -n "&NetworkInterface.2.IpAddress=static"
    echo -n "&NetworkInterface.2.NetworkId=net-0v3netj0"
    echo -n "&NetworkInterface.2.NetworkName="
    echo -n "&Password="
    echo -n "&Placement.AvailabilityZone=west-11"
    echo -n "&SecurityGroup.1=w11002wk"
    echo -n "&SignatureMethod=HmacSHA256"
    echo -n "&SignatureVersion=2"
    echo -n "&Timestamp=${request_date}"
})

echo -e "\n==== request string ===="
echo ${request_string}

# Create Signature
string_to_sign=$({
    echo -n "${request_method}\n"
    echo -n "${request_endpoint}\n"
    echo -n "${request_path}\n"
    echo -n "${request_string}"
})
request_signature=`echo -en ${string_to_sign} | openssl sha256 -hmac ${NIFCLOUD_SECRET_ACCESS_KEY} -binary | base64`
encoded_sigunature=$(urlencode ${request_signature})

echo -e "\n==== string to sign ===="
echo ${string_to_sign}
echo -e "\n==== signature ===="
echo ${request_signature}
echo -e "\n==== encoded signature ===="
echo ${encoded_sigunature}

# Create request
request=$({
    echo -n "https://${request_endpoint}${request_path}?"
    echo -n "${request_string}"
    echo -n "&Signature=${encoded_sigunature}"
})

echo -e "\n==== request ===="
echo ${request}

# Run request
echo -e "\n==== result ===="
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" ${request} 2>/dev/null | xmllint --format -
