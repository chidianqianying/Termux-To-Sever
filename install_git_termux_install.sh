#!/bin/bash
# Termux 自动化部署一键安装脚本 (GitHub版)
# 换源到清华源 + 下载主脚本 + 执行

echo "deb https://mirrors.tuna.tsinghua.edu.cn/termux/apt/termux-main stable main" > $PREFIX/etc/apt/sources.list
pkg update -y
pkg install -y wget
wget --no-check-certificate -O termux_install.sh "https://github.com/chidianqianying/Termux-To-Sever/releases/download/%E6%AD%A3%E5%BC%8F%E7%89%88/termux_install.sh"
chmod +x termux_install.sh
bash termux_install.sh
