#!/bin/bash

dac_svn_base="https://svn-domain/svn/project/CodeLib/project_name"
dac_tmp_workspace=/tmp/dac_tmp_workspace
MVN_HOME=/tools/apache-maven-3.3.9


echo -e "[INFO]Auto deploy start...\n\n\n"
read -p "Please input code branch name:" branch_name


#############################################################
# svn export

cd $dac_tmp_workspace

rm -rf $branch_name
if [ "$branch_name"x == "trunk"x ]; then
        svn export $dac_svn_base/$branch_name 
else
        svn export $dac_svn_base"/branches/"$branch_name
fi


if [ ! -d $dac_tmp_workspace/$branch_name ]; then
        echo "[ERROR] Download branch: "$branch_name" failed."
        exit 1
fi

#############################################################
# maven build

# deploy lib locally
echo -e "\n\n[INFO] Start install pboc_lib locally"
cd $dac_tmp_workspace/$branch_name/pboc_lib
$MVN_HOME/bin/mvn clean install


read -p "[Input]Which profile? [uat | sit | prod]: " prof
cd $dac_tmp_workspace/$branch_name/pboc_service
$MVN_HOME/bin/mvn clean package -P$prof


if [ ! -f $dac_tmp_workspace/$branch_name/pboc_service/target/pboc_service.war ]; then
        echo "[ERROR] maven build failed."
        exit 1
fi


#############################################################
# Deploy
echo -e "\n\n"
read -p "[Input]Target machine ip? Notice[uat->172.16.1.1, sit->172.16.1.2], input:" ip
read -p "[Input]Which environment? Example. uat-03-8983. input:" evnr


remote_tomcat_base=/home/dacadmin/$evnr/webapps/
ssh $ip "rm -rf $remote_tomcat_base/*"
scp $dac_tmp_workspace/$branch_name/pboc_service/target/pboc_service.war $ip:$remote_tomcat_base

#############################################################
# Done
echo "[INFO] Deploy Finished."

