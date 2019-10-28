#!/bin/bash

############################
# Usage:
# File Name: retag.sh
# Author: annhe  
# Mail: i@annhe.net
# Created Time: 2019-10-27 19:16:03
############################


REMOTE_REGISTRY=""
REGISTRY=$PRIVATE_REGISTRY
TAG="latest"
DEBUG="false"
BATCH=""

function _help() {
	echo -e "\nRetag docker image to private registry\n"
	echo -e "Usage: ./retag [OPTIONS]"
	echo -e "\t-r           remote registry domain"
	echo -e "\t-i           remote image"
	echo -e "\t-l           local image(if empty, same with remote image)"
	echo -e "\t-p           private registry domain"
	echo -e "\t-t           tag for docker image(default latest)"
	echo -e "\t-f           read from file"
	echo -e "\t-h|--help    print help info"
	exit 0
}

function _info() {
	echo -e "\033[32m[INFO] $1\033[0m"
}

function retag() {
	[ "$REGISTRY"x == ""x ] && echo "private registry domain is empty. Please use -p to provide it OR set PRIVATE_REGISTRY environment variable" && exit 1
	[ "$REMOTE_IMAGE"x == ""x ] && echo "Must provide remote image" && exit 1
	[ "$REMOTE_REGISTRY"x == ""x ] || REMOTE_REGISTRY="${REMOTE_REGISTRY}/"

	REMOTE=${REMOTE_REGISTRY}${REMOTE_IMAGE}:${TAG}
	LOCAL=${REGISTRY}/${LOCAL_IMAGE}:${TAG}

	_info "$REMOTE => $LOCAL"
	docker pull $REMOTE
	docker tag $REMOTE $LOCAL
	[ $DEBUG == "false" ] && docker push $LOCAL
}

function batch() {
	cat $1 |grep -vE "#|^$" | while read line;do
		REMOTE_IMAGE=`echo $line |awk '{print $1}'`
		LOCAL_IMAGE=`echo $line |awk '{print $2}'`
		TAG=`echo $line |awk '{print $3}'`
		REMOTE_REGISTRY=`echo $line |awk '{print $4}'`
		retag
	done
}

[ $# -lt 1 ] && _help

for i in "$@"
do
	key=$1
	case $key in
	-h|--help)
		_help
		exit 0;;
	-r)
		REMOTE_REGISTRY="$2"
		shift 2;;
	-i)
		REMOTE_IMAGE="$2"
		LOCAL_IMAGE=$REMOTE_IMAGE
		shift 2;;
	-l)
		LOCAL_IMAGE="$2"
		shift 2;;
	-p)
		REGISTRY="$2"
		shift 2;;
	-t)
		TAG="$2"
		shift 2;;
	-f)
		BATCH="$2"
		shift 2;;
	-d)
		DEBUG="true"
		shift;;
	*)
		shift;;
	esac
done

[ "$BATCH"x != ""x ] && batch $BATCH || retag
