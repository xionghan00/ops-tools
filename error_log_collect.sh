#!/bin/bash

cur_path='/tools'

server_list='user@ip:/logs/tomcat/project_name/error.log user@ip:/logs/tomcat02/project_name/error.log'


# 初始化，先把文件建起来，内容格式 {inode} ${filesize}
mkdir -p $cur_path/err_coll_tmp
cd $cur_path/err_coll_tmp
for serv in $server_list; do

        fname=`echo $serv | sed "s/\//|/g"`
        if [ ! -f $fname ]; then
                sip=`echo $serv | cut -d \: -f 1`
                slog=`echo $serv | cut -d \: -f 2`

                finfo=`ssh $sip "ls -l -i $slog" | awk '{print $1" "$6}'`
                echo $serv" -> "$finfo
                echo $finfo > "$fname"
        fi
done



errinfo=""
for serv in $server_list; do
        fname=`echo $serv | sed "s/\//|/g"`
        lastinode=`cat $fname| awk '{print $1}'`
        lastsize=`cat $fname| awk '{print $2}'`

        sip=`echo $serv | cut -d \: -f 1`
        slog=`echo $serv | cut -d \: -f 2`

        # 获取新的,并存到文件
        finfo=`ssh $sip "ls -l -i $slog" | awk '{print $1" "$6}'`

        echo $finfo > "$fname"


        inode=`echo $finfo | cut -d " " -f 1`
        size=`echo $finfo | cut -d " " -f 2`

        echo $inode
        echo $size 


        if [ $lastinode = $inode ]; then
                if [ $lastsize != $size ]; then
                        TFNAME=ERR_$RANDOM
                        t_errinfo=`ssh $sip "dd if=$slog of=/tmp/$TFNAME bs=1 skip=$lastsize && cat /tmp/$TFNAME && rm /tmp/$TFNAME"`
                        
                        
                        echo -e "${t_errinfo}"
                        t_msg="\n###########################"$serv"#########################\n"
                        t_msg="${t_msg}""\n""${t_errinfo}""\n"
                        t_msg="${t_msg}""\n#####################################################################################\n\n\n"

                        errinfo="${errinfo}""${t_msg}"
                fi
        else
                echo "rotate."
        fi
done


mail_list="xionghan00@126.com othermails@126.com"

if [ x"${errinfo}" != "x" ]; then
        echo -e "${errinfo}" | mail -s "DAC ERROR Log" $mail_list
fi
