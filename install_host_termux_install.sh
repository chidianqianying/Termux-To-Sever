#!/bin/bash
# Termux 自动化部署一键安装脚本 (备用服务器版)
# 换源到清华源 + 下载主脚本 + 执行

echo "deb https://mirrors.tuna.tsinghua.edu.cn/termux/apt/termux-main stable main" > $PREFIX/etc/apt/sources.list
pkg update -y
pkg install -y wget
wget --no-check-certificate -O termux_install.sh "https://cdqylua.dpdns.org/down.php/325d942aa2d3eb12f1f2ebac653536b7.sh"
chmod +x termux_install.sh
bash termux_install.sh
