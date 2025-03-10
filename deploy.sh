#!/usr/bin/env bash

# 1️⃣ 更新系统并安装 Node.js 和 npm
echo "Updating system and installing Node.js..."
sudo apt update --fix-missing
sudo apt install -y nodejs npm

# 2️⃣ 确保 Node.js 和 npm 正确安装
if ! command -v node &> /dev/null; then
    echo "Error: Node.js installation failed."
    exit 1
fi
if ! command -v npm &> /dev/null; then
    echo "Error: npm installation failed."
    exit 1
fi

# 3️⃣ 安装 pm2（如果已安装，则更新）
echo "Installing PM2..."
sudo npm install -g pm2
if ! command -v pm2 &> /dev/null; then
    echo "Error: PM2 installation failed."
    exit 1
fi

# 4️⃣ 停止旧的 pm2 进程
echo "Stopping any running instance of simpleapplication..."
pm2 stop simpleapplication || true  # 如果进程不存在，不报错

# 5️⃣ 进入应用目录
if [ ! -d "SimpleApplication" ]; then
    echo "Error: SimpleApplication directory not found!"
    exit 1
fi
cd SimpleApplication/

# 6️⃣ 安装依赖
echo "Installing dependencies..."
rm -rf node_modules package-lock.json
npm install

# 7️⃣ 处理密钥和证书
echo "Configuring private key and server certificate..."
echo -e "$PRIVATE_KEY" > private.pem
echo -e "$SERVER" > server.crt
chmod 600 private.pem server.crt  # 确保权限正确

# 8️⃣ 启动应用
echo "Starting application with PM2..."
pm2 start ./bin/www --name simpleapplication

# 9️⃣ 保存 PM2 进程，确保开机自启动
pm2 save
pm2 startup

echo "✅ Deployment completed successfully!"
