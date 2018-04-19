#!/bin/sh

cur_path=$(cd `dirname $0`; pwd)
tmp_dir=/tmp/deploy_upload

echo "[INFO] current path: $cur_path"
echo "[INFO]rebuild directory $tmp_dir"

rm -rf $tmp_dir
mkdir -p $tmp_dir

cd $tmp_dir
rz -bey

war_file_name=`ls $tmp_dir | grep '.war' | head -1`
if [ -z $war_file_name ]; then
    echo "[ERROR] can't find war file in $tmp_dir, quit..."
    exit
fi

read -p "[WARNING] find war file \"$tmp_dir/$war_file_name\", input [Y] to deploy : " go
case $go in
Y|y)
    echo "[INFO] start deploy..."

    cd $cur_path

    rm -rf $cur_path/webapps/ROOT/*
    cd $cur_path/webapps/ROOT/
    mv $tmp_dir/$war_file_name .

    echo "[INFO] start explode war file"
    jar -xf $war_file_name
    echo "[INFO] explode war file done"

    $cur_path/run.sh restart
    ;;
*)
    echo "[INFO] deploy abort, quit..."
    exit
    ;;
esac








