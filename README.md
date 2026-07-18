# Termux 自动化部署脚本

一键在 Android 上（仅限aarch64）部署 Ubuntu 20.04 + 宝塔面板 + Cloudflare 内网穿透。

## 快速开始

### 方式一：GitHub 下载（推荐）

```bash
cd && pkg install -y wget && wget --no-check-certificate -O termux_install.sh "https://github.com/chidianqianying/Termux-To-Sever/releases/download/%E6%AD%A3%E5%BC%8F%E7%89%88%EF%BC%9F/termux_install.sh" && chmod +x termux_install.sh && bash termux_install.sh
```

### 方式二：备用服务器下载

```bash
cd && pkg install -y wget && wget --no-check-certificate -O termux_install.sh "https://cdqylua.dpdns.org/down.php/d2cf13b0ef377de1feb99e3fdab272f4.sh" && chmod +x termux_install.sh && bash termux_install.sh
```

## 功能菜单

| 步骤 | 功能 |
|:---|:---|
| 1 | 安装准备环境（更新 Termux，安装 wget curl git proot） |
| 2 | 安装 Ubuntu 20.04（下载 rootfs，解压，配置 DNS，创建启动脚本，配置自启动） |
| 3 | 安装 Python（更新源，安装工具，添加 PPA，验证版本，时区提示） |
| 4 | 安装宝塔面板（下载安装脚本，执行安装，4步修复依赖） |
| 5 | 安装 Cloudflare 内网穿透（下载 cloudflared，验证，登录授权） |
| 6 | 配置 Cloudflare 内网穿透（创建隧道，自动获取 ID，询问穿透数量 1-9，交叉询问地址/域名，生成 config.yml，前台/后台启动） |
| 7 | 安装启动脚本（生成 ~/START.SH） |
| 8 | 结束 |

## 启动脚本（START.SH）

安装后运行 `~/START.SH` 管理：

| 选项 | 功能 |
|:---|:---|
| 1 | 以超级用户权限启动 Ubuntu |
| 2 | 启动 Ubuntu |
| 3 | 启动宝塔面板 |
| 4 | 启动 Cloudflare 内网穿透 |
| 5 | 修改 Cloudflare 内网穿透 |
| 6 | 退出 |

## 环境互锁

- **非 Ubuntu 环境**：只允许执行步骤 1-2
- **Ubuntu 环境**：只允许执行步骤 3-8
- **超绝防呆设计**：适配代码困难症

## 注意事项

1. 务必按顺序执行
2. 步骤 3 安装 Python 时，选时区中国用户请选择：第一次输入 6，第二次输入 70
3. 步骤 5 Cloudflare 登录需要浏览器访问 URL 授权
4. 步骤 6 配置穿透时，最多支持 9 组端口

## 开源协议

MIT License
