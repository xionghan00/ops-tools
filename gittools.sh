#!/bin/bash

refresh_tag(){
	tag_name=$1

	git tag -d ${tag_name}; git tag ${tag_name} && git push -f origin ${tag_name}
}

abc(){
	echo $1
}

$1 $2