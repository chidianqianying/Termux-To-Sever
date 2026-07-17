#!/bin/bash
# ============================================
# 自动化部署脚本
# 功能：环境准备 → Ubuntu 20.04 → Python → 宝塔面板 → Cloudflare 内网穿透 → 配置内网穿透
# ============================================

# 请求存储权限
termux-setup-storage

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 彩蛋列表
EASTER_EGGS=(
    "com.android.settings"
    "com.android.shell"
    "com.android.documentsui"
    "com.android.packageinstaller"
    "com.android.launcher"
    "android"
    "com.android.bluetooth"
    "com.android.permissioncontroller"
    "com.android.providers.media.module"
)

# 彩蛋函数
easter_egg() {
    local input="$1"
    case "$input" in
        "114514")
            echo -e "${RED}好臭的数字${NC}"
            ;;
        "2778")
            echo -e "${RED}真的吗${NC}"
            ;;
        "91")
            echo -e "${RED}你别这样${NC}"
            ;;
        "9178")
            echo -e "${RED}好恶俗${NC}"
            ;;
        "0721")
            echo -e "${RED}我会看的，我会看的${NC}"
            ;;
        *)
            local idx=$((RANDOM % ${#EASTER_EGGS[@]}))
            echo -e "${RED}已删除 \"${EASTER_EGGS[$idx]}\"${NC}"
            ;;
    esac
}

# 检测环境
check_env() {
    if [ -f "/etc/os-release" ]; then
        source /etc/os-release
        if echo "$ID" | grep -qi "ubuntu"; then
            echo "ubuntu"
        else
            echo "other"
        fi
    else
        echo "termux"
    fi
}

ENV_TYPE=$(check_env)

# 清屏并显示标题
clear
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}     自动化部署脚本 v1.0${NC}"
echo -e "${CYAN}     by 赤电の前影 | kimi2.6${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""
echo -e "${YELLOW}当前环境: ${ENV_TYPE}${NC}"
echo ""

while true; do
    echo -e "${YELLOW}请选择进行执行（务必按顺序执行）${NC}"
    echo -e "${GREEN}  1. 安装准备环境${NC}"
    echo -e "${GREEN}  2. 安装 Ubuntu 20.04${NC}"
    echo -e "${GREEN}  3. 安装 Python${NC}"
    echo -e "${GREEN}  4. 安装宝塔面板${NC}"
    echo -e "${GREEN}  5. 安装 Cloudflare 内网穿透${NC}"
    echo -e "${GREEN}  6. 配置 Cloudflare 内网穿透${NC}"
    echo -e "${GREEN}  7. 安装启动脚本${NC}"
    echo -e "${RED}  8. 结束${NC}"
    echo ""
    echo -n "请输入选项 [1-8]: "
    
    read choice
    
    # 环境权限验证
    if [ "$ENV_TYPE" != "ubuntu" ]; then
        if [ "$choice" = "3" ] || [ "$choice" = "4" ] || [ "$choice" = "5" ] || [ "$choice" = "6" ]; then
            echo ""
            echo -e "${RED}你不在ubuntu内！${NC}"
            echo ""
            continue
        fi
    fi
    
    if [ "$ENV_TYPE" = "ubuntu" ]; then
        if [ "$choice" = "1" ] || [ "$choice" = "2" ]; then
            echo ""
            echo -e "${RED}你在ubuntu内！${NC}"
            echo ""
            continue
        fi
    fi
    
    case $choice in
        1)
            echo ""
            echo -e "${BLUE}[步骤 1] 安装准备环境...${NC}"
            pkg update -y
            pkg upgrade -y
            pkg install -y wget curl git proot
            echo -e "${GREEN}✓ 准备环境安装完成${NC}"
            echo ""
            ;;
        2)
            echo ""
            echo -e "${BLUE}[步骤 2] 安装 Ubuntu 20.04...${NC}"
            cd ~
            git clone https://github.com/MFDGaming/ubuntu-in-termux.git
            cd ubuntu-in-termux
            cat ubuntu.sh | grep -i "ubuntu" | grep -i "tar"
            wget -c --tries=10 https://partner-images.canonical.com/core/focal/current/ubuntu-focal-core-cloudimg-arm64-root.tar.gz -O ubuntu-rootfs.tar.gz
            ls -lh ubuntu-rootfs.tar.gz
            file ubuntu-rootfs.tar.gz
            mkdir -p ubuntu-fs
            proot --link2symlink tar -xzf ubuntu-rootfs.tar.gz -C ubuntu-fs
            mkdir -p ubuntu-fs/etc
            echo "nameserver 8.8.8.8" > ubuntu-fs/etc/resolv.conf
            echo "nameserver 8.8.8.4" >> ubuntu-fs/etc/resolv.conf
            cat > startubuntu.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
cd $(dirname $0)
unset LD_PRELOAD
proot -0 -r ubuntu-fs -b /dev -b /proc -b /sys -b /sdcard -b /data -w /root /usr/bin/env -i HOME=/root PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin TERM=$TERM LANG=C.UTF-8 /bin/bash --login
EOF
            chmod +x startubuntu.sh
            if ! grep -q "startubuntu.sh" ~/.bashrc 2>/dev/null; then
                echo "" >> ~/.bashrc
                echo "# 自动启动 Ubuntu 20.04（后台并行）" >> ~/.bashrc
                echo "cd ~/ubuntu-in-termux && nohup ./startubuntu.sh >/dev/null 2>&1 &" >> ~/.bashrc
                echo -e "${GREEN}✓ 自启动已配置${NC}"
            else
                echo -e "${YELLOW}! 自启动已存在，跳过配置${NC}"
            fi
            nohup ./startubuntu.sh >/dev/null 2>&1 &
            echo -e "${GREEN}✓ Ubuntu 20.04 已在后台启动${NC}"
            echo -e "${GREEN}✓ Ubuntu 20.04 安装完成${NC}"
            echo ""
            ;;
        3)
            echo ""
            echo -e "${BLUE}[步骤 3] 安装 Python...${NC}"
            apt-get update
            apt-get install -y curl wget sudo software-properties-common python3-pip
            
            echo ""
            echo -e "${YELLOW}安装途中选时区中国用户请选择：第一次输入6，第二次输入70${NC}"
            echo -e "${YELLOW}输入 y 继续${NC}"
            while true; do
                echo -n "请输入: "
                read confirm
                if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                    break
                fi
                echo -e "${RED}✗ 输入错误，请重新输入${NC}"
                echo ""
            done
            
            add-apt-repository ppa:deadsnakes/ppa -y
            apt-get update
            python3 --version
            
            echo ""
            echo -e "${YELLOW}输出 Python 3.8.10 就是安装完毕${NC}"
            echo -e "${GREEN}✓ Python 安装完成${NC}"
            echo ""
            ;;
        4)
            echo ""
            echo -e "${BLUE}[步骤 4] 安装宝塔面板...${NC}"
            wget -O install.sh https://download.bt.cn/install/install-ubuntu_6.0.sh
            bash install.sh
            source /www/server/panel/pyenv/bin/activate && pip install requests pyinotify && pip install -r /www/server/panel/requirements.txt && /etc/init.d/bt start
            chmod -R 755 /www/server/panel && chown -R root:root /www/server/panel && source /www/server/panel/pyenv/bin/activate && pip install requests pyinotify && /etc/init.d/bt start
            source /www/server/panel/pyenv/bin/activate && pip install -r /www/server/panel/requirements.txt && /etc/init.d/bt start
            apt-get install -y locales && locale-gen en_US.UTF-8 && export LC_ALL=en_US.UTF-8 && export LANG=en_US.UTF-8 && source /www/server/panel/pyenv/bin/activate && pip install urllib3==1.26.18 six flask && /etc/init.d/bt restart
            echo -e "${GREEN}✓ 宝塔面板安装完成${NC}"
            echo ""
            ;;
        5)
            echo ""
            echo -e "${BLUE}[步骤 5] 安装 Cloudflare 内网穿透...${NC}"
            wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O /usr/local/bin/cloudflared
            chmod +x /usr/local/bin/cloudflared
            cloudflared --version
            chmod +x /usr/local/bin/cloudflared
            cloudflared --version
            
            echo ""
            echo -e "${YELLOW}请访问输出URL验证登录方可进行后续。${NC}"
            echo -e "${YELLOW}只有被授权的域名和分发子域才可以用于此处穿透。如果授权不完整可以手动执行 cloudflared tunnel login 命令再次授权！${NC}"
            echo -e "${YELLOW}输入 y 继续${NC}"
            while true; do
                echo -n "请输入: "
                read confirm
                if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                    break
                fi
                easter_egg "$confirm"
                echo -e "${RED}✗ 输入错误，请重新输入${NC}"
                echo ""
            done
            
            cloudflared tunnel login
            echo -e "${GREEN}✓ Cloudflare 内网穿透安装完成${NC}"
            echo ""
            ;;
        6)
            echo ""
            echo -e "${BLUE}[步骤 6] 配置 Cloudflare 内网穿透...${NC}"
            
            cloudflared tunnel create bt-panel
            
            echo ""
            echo -e "${CYAN}---------- 隧道列表 ----------${NC}"
            cloudflared tunnel list
            
            tunnel_id=$(cloudflared tunnel list | grep bt-panel | awk '{print $1}')
            creds_file="/root/.cloudflared/${tunnel_id}.json"
            
            echo "127.0.0.1 localhost" >> /etc/hosts
            echo "::1 localhost" >> /etc/hosts
            
            echo ""
            while true; do
                echo -e "${YELLOW}请输入需要对几个端口进行穿透（1~9）${NC}"
                echo -n "请输入: "
                read port_count
                
                if ! [[ "$port_count" =~ ^[0-9]+$ ]]; then
                    echo -e "${RED}就您这眼睛还玩Termux呢？${NC}"
                    echo ""
                    continue
                fi
                
                if [ "$port_count" -lt 1 ]; then
                    echo -e "${RED}你傻逼吧，信不信给你格机？${NC}"
                    echo ""
                    continue
                fi
                
                if [ "$port_count" -gt 9 ]; then
                    echo -e "${RED}你这么会用自己去跑命令行啊${NC}"
                    echo ""
                    continue
                fi
                
                break
            done
            
            echo ""
            echo -e "${YELLOW}你要是瞎写就自己手动配去吧。${NC}"
            echo -e "${YELLOW}输入 y 确认${NC}"
            while true; do
                echo -n "请输入: "
                read confirm
                if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                    break
                fi
                easter_egg "$confirm"
                echo -e "${RED}✗ 输入错误，请重新输入${NC}"
                echo ""
            done
            
            config_content="tunnel: ${tunnel_id}
credentials-file: ${creds_file}

ingress:"
            
            i=1
            while [ $i -le $port_count ]; do
                echo ""
                echo -e "${CYAN}--- 配置第 ${i} 组 ---${NC}"
                echo -n "请输入被穿透地址（带端口）: "
                read service_addr
                echo -n "请输入域名: "
                read domain
                config_content="${config_content}
  - hostname: ${domain}
    service: http://${service_addr}"
                i=$((i + 1))
            done
            
            config_content="${config_content}
  - service: http_status:404"
            
            cat > /root/config.yml << EOF
${config_content}
EOF
            
            echo ""
            echo -e "${CYAN}---------- 配置已生成 ----------${NC}"
            cat /root/config.yml
            
            echo ""
            echo -e "${YELLOW}是否后台启动？（y/n）${NC}"
            echo -n "请输入: "
            read bg_choice
            if [ "$bg_choice" = "y" ] || [ "$bg_choice" = "Y" ]; then
                nohup cloudflared tunnel --config /root/config.yml --protocol http2 run > /dev/null 2>&1 &
                echo -e "${GREEN}✓ 已后台启动（HTTP/2 协议）${NC}"
            else
                echo -e "${YELLOW}前台启动中，按 Ctrl+C 停止...${NC}"
                cloudflared tunnel --config /root/config.yml run
            fi
            
            echo -e "${GREEN}✓ Cloudflare 内网穿透配置完成${NC}"
            echo ""
            ;;
        7)
            echo ""
            echo -e "${BLUE}[步骤 7] 安装启动脚本...${NC}"
            cd ~
            cat > START.SH << 'STARTEOF'
#!/bin/bash
# ============================================
# START.SH - 启动管理脚本
# ============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}     启动管理脚本${NC}"
echo -e "${CYAN}     by 赤电の前影 | kimi2.6${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

while true; do
    echo -e "${YELLOW}请选择操作${NC}"
    echo -e "${GREEN}  1. 以超级用户权限启动 Ubuntu${NC}"
    echo -e "${GREEN}  2. 启动 Ubuntu${NC}"
    echo -e "${GREEN}  3. 启动宝塔面板${NC}"
    echo -e "${GREEN}  4. 启动 Cloudflare 内网穿透${NC}"
    echo -e "${GREEN}  5. 修改 Cloudflare 内网穿透${NC}"
    echo -e "${RED}  6. 退出${NC}"
    echo ""
    echo -n "请输入选项 [1-6]: "
    read schoice
    
    case $schoice in
        1)
            echo ""
            echo -e "${BLUE}[1] 以超级用户权限启动 Ubuntu...${NC}"
            su -c "cd /data/data/com.termux/files/home/ubuntu-in-termux && unset LD_PRELOAD && /data/data/com.termux/files/usr/bin/proot -0 -r ubuntu-fs -b /dev -b /proc -b /sys -b /sdcard -b /data -w /root /usr/bin/env -i HOME=/root PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin TERM=linux LANG=C.UTF-8 /bin/bash --login"
            if [ $? -ne 0 ]; then
                echo -e "${RED}你在干鸡毛！！！${NC}"
            fi
            echo ""
            ;;
        2)
            echo ""
            echo -e "${BLUE}[2] 启动 Ubuntu...${NC}"
            cd ~/ubuntu-in-termux && ./startubuntu.sh
            echo ""
            ;;
        3)
            echo ""
            echo -e "${BLUE}[3] 启动宝塔面板...${NC}"
            bt start
            echo -e "${GREEN}✓ 宝塔面板已启动${NC}"
            echo ""
            ;;
        4)
            echo ""
            echo -e "${BLUE}[4] 启动 Cloudflare 内网穿透...${NC}"
            cloudflared tunnel --config /root/config.yml run bt-panel
            echo ""
            ;;
        5)
            echo ""
            echo -e "${BLUE}[5] 修改 Cloudflare 内网穿透...${NC}"
            
            tunnel_id=$(cloudflared tunnel list | grep bt-panel | awk '{print $1}')
            creds_file="/root/.cloudflared/${tunnel_id}.json"
            
            rm -f ~/.cloudflared/config.yml
            
            echo ""
            while true; do
                echo -e "${YELLOW}请输入需要对几个端口进行穿透（1~9）${NC}"
                echo -n "请输入: "
                read port_count
                
                if ! [[ "$port_count" =~ ^[0-9]+$ ]]; then
                    echo -e "${RED}就您这眼睛还玩Termux呢？${NC}"
                    echo ""
                    continue
                fi
                
                if [ "$port_count" -lt 1 ]; then
                    echo -e "${RED}你傻逼吧，信不信给你格机？${NC}"
                    echo ""
                    continue
                fi
                
                if [ "$port_count" -gt 9 ]; then
                    echo -e "${RED}你这么会用自己去跑命令行啊${NC}"
                    echo ""
                    continue
                fi
                
                break
            done
            
            echo ""
            echo -e "${YELLOW}你要是瞎写就自己手动配去吧。${NC}"
            echo -e "${YELLOW}输入 y 确认${NC}"
            while true; do
                echo -n "请输入: "
                read confirm
                if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                    break
                fi
                echo -e "${RED}✗ 输入错误，请重新输入${NC}"
                echo ""
            done
            
            config_content="tunnel: ${tunnel_id}
credentials-file: ${creds_file}

ingress:"
            
            i=1
            while [ $i -le $port_count ]; do
                echo ""
                echo -e "${CYAN}--- 配置第 ${i} 组 ---${NC}"
                echo -n "请输入被穿透地址（带端口）: "
                read service_addr
                echo -n "请输入域名: "
                read domain
                config_content="${config_content}
  - hostname: ${domain}
    service: http://${service_addr}"
                i=$((i + 1))
            done
            
            config_content="${config_content}
  - service: http_status:404"
            
            cat > /root/config.yml << EOF
${config_content}
EOF
            
            echo ""
            echo -e "${CYAN}---------- 配置已生成 ----------${NC}"
            cat /root/config.yml
            
            echo ""
            echo -e "${YELLOW}是否后台启动？（y/n）${NC}"
            echo -n "请输入: "
            read bg_choice
            if [ "$bg_choice" = "y" ] || [ "$bg_choice" = "Y" ]; then
                nohup cloudflared tunnel --config /root/config.yml --protocol http2 run bt-panel > /dev/null 2>&1 &
                echo -e "${GREEN}✓ 已后台启动（HTTP/2 协议）${NC}"
            else
                echo -e "${YELLOW}前台启动中，按 Ctrl+C 停止...${NC}"
                cloudflared tunnel --config /root/config.yml run bt-panel
            fi
            
            echo -e "${GREEN}✓ Cloudflare 内网穿透修改完成${NC}"
            echo ""
            ;;
        6)
            echo ""
            echo -e "${CYAN}如果你是手动安装的，你就会发现我的脚本相当一部分功能你用不了哦${NC}"
            break
            ;;
        *)
            echo ""
            echo -e "${RED}✗ 无效选项，请输入 1-6 之间的数字${NC}"
            echo ""
            ;;
    esac
done
STARTEOF
            chmod +x ~/START.SH
            echo -e "${GREEN}✓ START.SH 已生成到 ~/START.SH${NC}"
            echo ""
            ;;
        8)
            echo ""
            echo -e "${CYAN}感谢使用，脚本已退出。${NC}"
            break
            ;;
        *)
            echo ""
            easter_egg "$choice"
            echo ""
            ;;
    esac
done
