#! /bin/bash

cd /home/$USER/
echo "choose the download mode:"
echo "1.index-mixed"
echo "2.index-index"
echo "3.download directly"
read -p "enter the mode:" mode
if [ $mode -eq 1 ]; then
    read -p "m3u8 link:" m3u8link
    wget -q $m3u8link   #获取初始链接
    mix=$(sed -n 3p /home/$USER/index.m3u8)
    rm /home/$USER/index.m3u8
    mixed=${m3u8link%index.m3u8}
    mixed+=$mix
    wget -q $mixed  #获取混淆文件
    if test -f "/home/$USER/index.m3u8"; then
        mv /home/$USER/index.m3u8 /home/$USER/mixed.m3u8
        ts=${mixed%index.m3u8}
    else
        ts=${mixed%mixed.m3u8}
    fi
    read -p "video name:" vname
    tr=$(sed -n 8p "/home/$USER/mixed.m3u8")
    ts+=$tr
    trans=${tr%0000.ts}
    tslink=${ts%0000.ts}
    dz="$"
    dz+=0
    echo "please open new command line and run:awk '{gsub(\"$trans\", \"$tslink\",$dz); print}' \"/home/$USER/mixed.m3u8\" > \"/home/$USER/mixed2.m3u8\""    #链接文本替换
    while true; do  #循环检测是否运行上一命令
        sleep 1
        if test -f "/home/$USER/mixed2.m3u8"; then
            rm /home/$USER/mixed.m3u8
            mv /home/$USER/mixed2.m3u8 /home/$USER/mixed.m3u8
            break
        fi
    done
    ffmpeg -protocol_whitelist "concat,file,http,https,tcp,tls,crypto,data" -i "/home/$USER/mixed.m3u8" -c copy "/home/$USER/$vname.mp4"  #文件下载
    echo "download complete"
    rm /home/$USER/mixed.m3u8
elif [ $mode -eq 2 ]; then
    read -p "m3u8 link" m3u8link
    wget -q $m3u8link
    mix=$(sed -n 3p /home/$USER/index.m3u8)
    rm /home/$USER/index.m3u8
    mixed=${m3u8link%index.m3u8}
    mixed+=$mix
    wget -q $mixed
    read -p "video name" vname
    ffmpeg -protocol_whitelist "concat,file,http,https,tcp,tls,crypto,data" -i "/home/$USER/index.m3u8" -c copy "/home/$USER/$vname.mp4"
    echo "download complete"
    rm /home/$USER/index.m3u8
elif [ $mode -eq 3 ]; then
    read -p "video link" vlink
    read -p "video name" vname
    ffmpeg -protocol_whitelist "concat,file,http,https,tcp,tls,crypto,data" -i $vlink -c copy "/home/$USER/$vname.mp4"
    echo "download complete"
fi
