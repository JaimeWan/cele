
# celestia 轻节点 docker启动脚本 version==sha-747c9e5
### 简单启动 
docker run -e NODE_TYPE=light -e P2P_NETWORK=mocha ghcr.io/celestiaorg/celestia-node:sha-747c9e5 celestia light start --core.ip https://rpc-mocha.pops.one --gateway --gateway.addr 127.0.0.1 --gateway.port 26659 --p2p.network mocha

# 脚本启动
## linux系统需要 centos7.6 64bit
### 1.下载脚本,上传至服务器
### 2.执行 chmod u+x cele-start.sh && ./cele-start.sh
### 3.执行完成后 ,找到当前文件夹下files/keys 文件夹(下载保存后备份),钱包助记词和钱包地址已经存在该文件夹下的keys.txt中,其他文件为节点启动时需要的私钥文件.
### 4.执行docker-compose up -d && docker-compose logs  启动节点并打开日志
