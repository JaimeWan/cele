#!/bin/bash
# This script is used to start the Celestia application
# if not exist ".\files" create ".\files"
if [ ! -d "./files" ]; then
mkdir ./files
fi

# 检查是否安装docker,如果已经安装则提示并跳过,未安装则安装docker,自动选择最新版本,出现选择界面时选择y,然后回车,等待安装完成
if [ ! -f "/usr/bin/docker" ]; then
    echo "未安装docker,开始安装docker"
    curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
    echo "docker安装完成,启动docker"
    systemctl start docker
fi
echo "docker已安装"

# 修改系统时间为北京时间
TZ='Asia/Shanghai'; export TZ


# 检查docker-compose是否安装,如果已经安装则提示并跳过
if [ ! -f "/usr/local/bin/docker-compose" ]; then
 # centos安装docker-compose
 echo "未安装docker-compose,开始安装docker-compose"
 sudo curl -L "https://github.com/docker/compose/releases/download/1.29.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
 sudo chmod +x /usr/local/bin/docker-compose
 echo $PATH
 export PATH=$PATH:/usr/local/bin
fi
echo "docker-compose已安装"




# 启动临时docker镜像
echo "启动一个临时镜像"
docker run -itd --name temp -e NODE_TYPE=light -e P2P_NETWORK=mocha ghcr.io/celestiaorg/celestia-node:0.6.3 celestia light start --core.ip https://rpc-mocha.pops.one --gateway --gateway.addr 127.0.0.1 --gateway.port 26659 --p2p.network mocha

# 等待30秒
sleep 30

# 导出docker日志
docker logs temp > "./temp.log"

# 获取日志中的第11行
line=$(sed -n '11p' ./temp.log)
# 获取line ADDRESS: 后面的内容

# 获取日志中的第13行
line2=$(sed -n '13p' ./temp.log)


# 获取line中的地址
address=$(echo $line | awk -F 'ADDRESS: ' '{print $2}')
# 去除address中的换行符
address=${address//[$'\t\r '

]}
# 复制docker容器中的keys文件夹到./files/keys
docker cp temp:/root/.celestia-light-mocha/keys "./files/keys"

# line和输出到./files/keys.txt文件中
echo "$line" > "./files/keys/keys.txt"
# line2和输出到./files/keys.txt文件中
echo "$line2" >> "./files/keys/keys.txt"

# 备份keys文件夹到./files/$address/keys/keys
mkdir -p "./files/$address"
cp -r "./files/keys" "./files/$address"
# 将./files/$address文件夹压缩为./files/$address.zip
zip -r "./files/$address.zip" "./files/$address"
echo "导出私钥及文件完毕"

# 删除docker容器
echo "删除临时容器"
docker rm -f temp

# 删除temp.log文件
echo "删除临时日志文件"
rm -rf ./temp.log

# 根据字符串生成yml文件
echo "生成docker-compose.yml文件"
echo "services:
    light_node:
        image: \"ghcr.io/celestiaorg/celestia-node:0.6.3\"
        command: >
            celestia light start
            --core.ip https://rpc-mocha.pops.one
            --gateway
            --gateway.addr 0.0.0.0
            --gateway.port 26659
            --p2p.network mocha
            --keyring.accname my_celes_key
        environment:
            - NODE_TYPE=light
            - P2P_NETWORK=mocha
        volumes:
            - /root/files/keys:/root/.celestia-light-mocha/keys
        ports:
            - 127.0.0.1:26659:26659
" > "./docker-compose.yml"

echo "===================================================================================================="
echo "启动celestia节点命令,请复制到终端执行: docker-compose up"
echo "启动celestia节点命令(后台执行),请复制到终端执行: docker-compose up -d"
echo "停止celestia节点命令,请复制到终端执行: docker-compose down"
echo "查看celestia节点日志命令(后台执行),请复制到终端执行: docker-compose logs -f"
echo "查看celestia节点状态命令(后台执行),请复制到终端执行: docker-compose ps"

echo "===================================================================================================="
echo "脚本结束,请查看下面的输出信息,妥善保存!!!!!!!!!!!!!!"

# 获取当前时间并赋值给变量
now=$(date +"%Y-%m-%d %H:%M:%S")
#输出keys文件夹路径
echo "当前时间: $now"
echo
echo -e "妥善保存助记词,私钥文件夹及keys.txt文件,请勿丢失!!!!!!!!!!!!!!"
echo
echo -e "本地备份路径(用于下载到本地保存,请勿丢失!!!!!!!!!!!!!!):\n /root/files/$address/keys"
echo
echo -e "私钥文件夹路径(当前文件执行所需的私钥文件夹,请勿删除):\n /root/files/keys"
echo
# 输出keys.txt文件路径及内容
echo -e "助记词及keys文件夹路径:\n /root/files/keys"
echo
echo "地址和助记词: "
echo "===================================================================================================="
cat "/root/files/keys.txt"
