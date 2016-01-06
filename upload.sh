#!/bin/bash
# author: lgw51
# date: 2016-01-06

IPAFile="$1"
ApiToken="you api token"
Type="ios"
ReleaseType="Adhoc" #Inhouse
ChangeLog="$2"
AppName="app name"

Date=`date +%Y%m%d%H%M`
unzipPlist="/tmp/Info_$Date.plist"
unzip -p $IPAFile "Payload/$AppName.app/Info.plist" > $unzipPlist
BundleId=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" $unzipPlist)
AppName=$(/usr/libexec/PlistBuddy -c "Print :CFBundleName" $unzipPlist)
AppVersion=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" $unzipPlist)
AppBuild=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" $unzipPlist)
rm -rf $unzipPlist

eval $(curl -X POST -H "Content-Type: application/json" -d "{\"type\":\"$Type\", \"bundle_id\":\"$BundleId\", \"api_token\":\"$ApiToken\"}" http://api.fir.im/apps  2>/dev/null | ./JSON.sh -b | awk '{gsub(/[\]["]/, "", $1); gsub(",", "_", $1); print $1 "=" $2; }')

curl -F "key=$cert_binary_key" -F "token=$cert_binary_token" \
    -F "file=@$IPAFile" -F "x:name=$AppName" -F "x:version=$AppVersion" \
    -F "x:build=$AppBuild" -F "x:release_type=$ReleaseType" -F "x:changelog=$ChangeLog" \
    $cert_binary_upload_url
