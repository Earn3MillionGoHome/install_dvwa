#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 恢复默认颜色

# 装饰性函数
print_header() {
    clear
    echo -e "${GREEN}"
    echo "===================================================================="
    echo "   ██████  ██    ██ ██     ██  █████   Installer   "
    echo "  ██    ██ ██    ██ ██     ██ ██   ██ "
    echo "  ██    ██ ██    ██ ██  █  ██ ███████ "
    echo "  ██ ▄▄ ██ ██    ██ ██ ███ ██ ██   ██ "
    echo "   ██████   ██████   ███ ███  ██   ██ "
    echo "===================================================================="
    echo -e "${NC}"
}

print_step() {
    echo -e "${YELLOW}[+] ${1}${NC}"
}

print_success() {
    echo -e "${GREEN}[✓] ${1}${NC}"
}

print_error() {
    echo -e "${RED}[✗] ${1}${NC}"
}

print_progress() {
    echo -n -e "${BLUE}    ${1}... ${NC}"
}

# 检查root权限
if [ "$EUID" -ne 0 ]; then
    print_error "请使用sudo运行此脚本"
    exit 1
fi

print_header

# 安装依赖
print_step "第一步：安装系统依赖"
print_progress "更新软件源"
apt update -qq > /dev/null 2>&1
print_success "完成"

print_progress "安装必要软件包"
apt install -qq -y apache2 mariadb-server php php-mysqli php-gd libapache2-mod-php unzip > /dev/null 2>&1
print_success "完成"

# 配置数据库
print_step "第二步：配置数据库"
print_progress "启动MySQL服务"
systemctl start mariadb > /dev/null 2>&1
systemctl enable mariadb > /dev/null 2>&1
print_success "完成"

print_progress "创建数据库和用户"
mysql -uroot <<-EOF > /dev/null 2>&1
CREATE DATABASE dvwa;
CREATE USER 'dvwa'@'localhost' IDENTIFIED BY 'p@ssw0rd';
GRANT ALL PRIVILEGES ON dvwa.* TO 'dvwa'@'localhost';
FLUSH PRIVILEGES;
EOF
print_success "完成"

# 下载DVWA
print_step "第三步：安装DVWA"
print_progress "下载源代码"
wget -q https://github.com/digininja/DVWA/archive/master.zip -O /tmp/dvwa.zip
print_success "完成"

print_progress "解压文件"
unzip -q /tmp/dvwa.zip -d /var/www/html/ > /dev/null 2>&1
mv /var/www/html/DVWA-master /var/www/html/dvwa
print_success "完成"

# 配置文件设置
print_step "第四步：配置应用"
print_progress "设置权限"
chown -R www-data:www-data /var/www/html/dvwa
chmod -R 755 /var/www/html/dvwa
print_success "完成"

print_progress "创建配置文件"
cp /var/www/html/dvwa/config/config.inc.php.dist /var/www/html/dvwa/config/config.inc.php
sed -i "s/'db_password' = 'p@ssw0rd'/'db_password' = 'p@ssw0rd'/" /var/www/html/dvwa/config/config.inc.php
print_success "完成"

# PHP配置
print_step "第五步：PHP配置"
print_progress "修改php.ini设置"
sed -i "s/allow_url_include = Off/allow_url_include = On/" /etc/php/7.4/apache2/php.ini
print_success "完成"

# 重启服务
print_step "最后一步：重启服务"
print_progress "重启Apache"
systemctl restart apache2 > /dev/null 2>&1
print_success "完成"

# 显示结果
print_header
echo -e "${GREEN}
安装成功！请通过以下地址访问：

DVWA 地址: http://$(hostname -I | awk '{print $1}')/dvwa
登录凭证:
  用户名: admin
  密码: password

安全提示:
1. 本脚本仅用于测试环境！
2. 安装完成后请立即修改默认密码！
3. 不要在生产环境使用此配置！

使用方法：
1. 将脚本保存为 install_dvwa.sh
2. 添加执行权限：chmod +x install_dvwa.sh
3. 使用sudo运行：sudo ./install_dvwa.sh
${NC}"
