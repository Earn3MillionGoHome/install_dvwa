# DVWA 自动安装脚本描述

该脚本旨在自动化部署 DVWA (Damn Vulnerable Web Application) 测试环境，专为 Debian/Ubuntu 系统设计。通过一系列自动化步骤，脚本不仅完成了系统依赖的安装，还配置了数据库、部署了 DVWA 应用，并调整了 PHP 设置，确保测试环境能够顺利运行。

## 脚本功能概览

1. **彩色输出与用户提示**  
   - 定义了红、绿、黄、蓝等颜色变量，利用 `print_header`、`print_step`、`print_success`、`print_error` 和 `print_progress` 函数，在终端输出彩色提示信息，帮助用户直观了解安装进度和结果。

2. **权限检查**  
   - 在运行开始前检查当前用户是否具备 root 权限。如果检测到权限不足，脚本会提示用户使用 `sudo` 运行，确保所有系统操作能够顺利执行。

3. **系统依赖安装**  
   - 自动更新软件源，并安装 Apache2、MariaDB、PHP 及其必要扩展（包括 `php-mysqli`、`php-gd`、`libapache2-mod-php` 和 `unzip`），为 DVWA 的正常运行提供环境支持。

4. **数据库配置**  
   - 启动 MariaDB 服务并设置为开机自启。  
   - 自动创建名为 `dvwa` 的数据库及对应用户（用户名：dvwa，密码：p@ssw0rd），并赋予必要的访问权限，确保 DVWA 能正确连接数据库。

5. **DVWA 部署**  
   - 通过 `wget` 从 GitHub 下载 DVWA 源码压缩包，并解压到 `/var/www/html/dvwa` 目录。  
   - 调整文件和目录权限，确保 Web 服务器 Apache 能够正确读取和执行 DVWA 文件。

6. **应用配置**  
   - 复制 DVWA 默认配置文件，并根据需要修改数据库连接设置，确保 DVWA 能够顺利访问前面配置好的数据库。

7. **PHP 配置调整**  
   - 修改 PHP 配置文件 `php.ini`，启用 `allow_url_include` 选项，满足 DVWA 对 PHP 配置的要求。

8. **服务重启**  
   - 最后重启 Apache 服务，使所有配置变更生效，并在终端输出 DVWA 访问地址及默认登录凭证（用户名：admin，密码：password）。

## 使用方法

- **保存脚本**：将该脚本保存为 `install_dvwa.sh`。  
- **赋予执行权限**：在终端中执行  
  ```bash
  chmod +x install_dvwa.sh
以 root 用户或 sudo 运行脚本：
bash
复制
编辑
sudo ./install_dvwa.sh
访问 DVWA：安装完成后，脚本会在终端显示 DVWA 的访问 URL，使用浏览器访问即可进入 DVWA 登录页面。
注意事项
测试环境专用：
该脚本仅用于测试环境，不建议在生产环境中使用。

安全性：
安装完成后，请立即修改默认数据库密码和 DVWA 登录凭证，避免潜在的安全风险。

系统兼容性：
脚本中使用的命令和路径基于 Debian/Ubuntu 系统，其他 Linux 发行版可能需要适当调整。

## 免责声明

该工具仅供安全研究和渗透测试用途，请勿用于非法目的！使用本工具造成的任何法律责任由用户自行承担。
