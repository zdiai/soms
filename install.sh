#!/bin/bash
#############################################################################################
echo "安装pip3，mysql，redis，mongodb，和一些python的组件"
sudo apt-get update

dpkg -l mongodb-server* >> /dev/null
if [ $? -ne 0 ];then
        sudo apt-get install mongodb-server -y >> /dev/null && echo "mongodb-server安装完成"
else
        echo " mongodb-server已经安装，此次未安装"
fi

dpkg -l mysql-server >> /dev/null
if [ $? -ne 0 ];then
       sudo apt-get install mysql-server-5.7 -y >> /dev/null && echo "mysql-server安装完成"
####################################################################Mysql数据库设置####################
mysqlpasswd=`(grep password /etc/mysql/debian.cnf | head -1 | awk -F " = " '{ print $2 }')`
export MYSQL_PWD=$mysqlpasswd
mysql -u root  <<EOF
use mysql;
select plugin from user where user = 'root';
update user set plugin='mysql_native_password';
update user set authentication_string=password('123456') where user='root' and host='localhost';
flush privileges;
EOF
export MYSQL_PWD=123456
ls $PWD/*.sql
if [ $? -eq 0 ]; then
mysql -u root -p123456 <<EOF
CREATE DATABASE IF Not EXISTS ship_soms_v3;
use ship_soms_v3;
source $PWD/*.sql;
EOF
elif [ $? -ne 0 ]; then
	echo "ERROR $PWD NO SQL FILE!!"
fi

echo "解压软件包"
	else
        echo " mysql-server-5.7 已经安装，此次未安装,未创建库，未还原库。"
fi

dpkg -l redis-server >> /dev/null
if [ $? -ne 0 ];then
        sudo apt-get install redis-server -y >> /dev/null && echo "redis-server安装完成"
	else
        echo " redis-server已经安装，此次未安装"
	fi
####################################################################################################
sudo apt-get install python3-pip qt4*  gunicorn -y >> /dev/null&& echo "qt4 gunicorn python3 安装完成"
#tar -zvxf $PWD/pyg.tar.gz >> /dev/null && echo "解压python依赖包"
sudo pip3 install pandas sqlalchemy redis pymongo shapely -i https://pypi.tuna.tsinghua.edu.cn/simple >> /dev/null
pip3 install --no-index --find-links=$PWD/py_pkg -r /$PWD/py_pkg.txt >> /dev/null && echo "离线安装python依赖包"

#########################################################################################
mkdir -pv /var/soms/data/efficiency/{cltupload,serupload,sersendmessage,cltdownload}
chmod 755 -R /var/soms/
############################################################################################# 安装TV
cd $PWD
dpkg -i teamviewer*.deb
if [ $? -ne 0 ]; then
	apt-get install -f -y && dpkg -i teamviewer*.deb
fi

dpkg -l unzip >> /dev/null
if [ $? -eq 1 ]; then
apt install unzip -y
fi

cd /opt/
Tarlist=`ls -d "*.tar.gz"`
Ziplist=`ls -d "*.zip"`

for tar in $Tarlist; do
tar -xkf $tar -C /opt/
if [ $? -eq 0 ]; then
	echo "$tar 解压完成删除压缩包" && rm -rf $tar
elif [ $? -ne 0 ]; then
	echo "$tar解压文件已存在，五秒钟考虑时间，是否覆盖Y/N"
	read MMB -s 5
	case "$MMB" in
		[yY]) tar -zxf $tar -C /opt/ && rm -rf $tar
			echo "$tar 解压完成删除压缩包"
			;;
		[nN]) echo "$tar保留了原文件 压缩包未删除"
			;;
		*) echo "输入错误，保留原文件，压缩包未删除"
	esac
fi
done

for zip in $Ziplist;
do
	unzip -dq /opt/  $zip
	if [ $? -eq 0 ]; then
		echo "$zip 解压完成，删除压缩包" && rm -rf $zip
	fi
done

chmod 755 -R /opt/*
chown seri:root -R /opt/*

echo "设置能效和海图开机自启"
cd /opt/tomcat-eff/bin
cp catalina.sh /etc/init.d/tomcateff
cd /opt/tomcat-geo/bin
cp catalina.sh /etc/init.d/tomcatgeo

echo -e '#!/bin/bash
#接口
cd /opt/efzFlaskB_03
nohup gunicorn -w 4 -k gevent -b 0.0.0.0:5000 mainApp:app > /dev/null 2>&1 &
nohup python3 staticShipsData_ship.py > /dev/null 2>&1 &
nohup python3 AlarmJudgment2.py > /dev/null 2>&1 &
nohup python3 GXMiddleware.py > /dev/null 2>&1 &

# 船端控制模块
cd /opt/Control/
nohup python3 controlClient.py > /dev/null 2>&1 &

# 船端通信模块
cd /opt/TCPMaster1/
nohup python3 somsClient.py > /dev/null 2>&1 &

#数据采集服务
cd /opt/py-soms
nohup python3 soms_collect_module.py> /dev/null 2>&1 &

#能效系统
/etc/init.d/tomcateff start

#海图服务
/etc/init.d/tomcatgeo start
#气象服务
nohup sudo bash /opt/BINECDIS/tomcat_qixiang.sh > /dev/null 2>&1 &

exit 0
' > /etc/rc.local

cd /opt/moxa/ && echo N | ./mxinst m64
