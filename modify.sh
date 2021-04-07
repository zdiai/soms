#!/bin/bash
source $PWD/somsconfig.sh
echo  "采集软件修改船名，检查以下内容是否正确"
Yname23=`(cat -n /opt/py-soms/config.json  | grep 23 | awk -F "\"" '{ print $28 }')`
Yname24=`(cat -n /opt/py-soms/config.json  | grep 24 | awk -F "\"" '{ print $28 }')`
Yname25=`(cat -n /opt/py-soms/config.json  | grep 25 | awk -F "\"" '{ print $28 }')`
Yname26=`(cat -n /opt/py-soms/config.json  | grep 26 | awk -F "\"" '{ print $28 }')`
Yname27=`(cat -n /opt/py-soms/config.json  | grep 27 | awk -F "\"" '{ print $28 }')`
Yname28=`(cat -n /opt/py-soms/config.json  | grep 28 | awk -F "\"" '{ print $28 }')`
Yname29=`(cat -n /opt/py-soms/config.json  | grep 29 | awk -F "\"" '{ print $28 }')`
#Yname=`(awk -F ":" '{ print $8 }' /opt/py-soms/config.json | sed -n '24p' |awk -F ""\" '{print $2}')`
sed -i "s/$Yname23/$Vesselname"_Com"/" /opt/py-soms/config.json > /dev/null 2>&1
sed -i "s/$Yname24/$Vesselname/" /opt/py-soms/config.json > /dev/null 2>&1
sed -i "s/$Yname25/$Vesselname"_5s"/" /opt/py-soms/config.json > /dev/null 2>&1
sed -i "s/$Yname26/$Vesselname"_30s"/" /opt/py-soms/config.json > /dev/null 2>&1
sed -i "s/$Yname27/$Vesselname"_5min"/" /opt/py-soms/config.json > /dev/null 2>&1
sed -i "s/$Yname28/$Vesselname"_1hour"/" /opt/py-soms/config.json > /dev/null 2>&1
sed -i "s/$Yname29/$Vesselname"_1day"/" /opt/py-soms/config.json > /dev/null 2>&1
#rm name.txt
grep -e $Vesselname /opt/py-soms/config.json && sleep 3
echo "检查小木马船名配置"
Cname=`(sed -n 4p /opt/Control/control.ini | awk -F " " '{ print $3 }')`
sed -i "s/$Cname/$Vesselname/" /opt/Control/control.ini
grep -e $Vesselname /opt/Control/control.ini && sleep 2
#sed -i ‘s/^M//g /opt/Control/control.ini

#echo "修改tcp回传名称和接口"
Ycname=`(sed -n 22p /opt/TCPMaster1/somsCommun.ini | awk -F " " '{print $3}')`
Tcname=`(sed -n 14p /opt/TCPMaster1/somsCommun.ini | awk -F " " '{print $3}')`
sed -i "s/$Ycname/$TCPprot/" /opt/TCPMaster1/somsCommun.ini
sed -i "s/$Tcname""/$Vesselname"_Com"/" /opt/TCPMaster1/somsCommun.ini

echo "检查回传脚本"
grep -e $TCPprot /opt/TCPMaster1/somsCommun.ini
grep -e $Vesselname /opt/TCPMaster1/somsCommun.ini && sleep 3

#echo  "修改接口的船端名称"
EFname=`(sed -n 42p /opt/efzFlaskB_03/main.ini | awk -F " " '{ print $3 }')`
sed -i "s/$EFname/$Vesselname/" /opt/efzFlaskB_03/main.ini
sed -i "s/^M//g" /opt/efzFlaskB_03/main.ini


echo "请检查接口船名修改是否正确,并手动修改列出的其他三项！"
grep  shipName /opt/efzFlaskB_03/main.ini -A 3 && sleep 2
echo "修改能效系统IP地址"

QSIP=`(grep geoserver /opt/tomcat-eff/webapps/ROOT/WEB-INF/classes/theme-day.properties  |cut -d "/" -f 3 | cut -d ":" -f 1)`
sed -i "s/$QSIP/$VesselIP/" /opt/tomcat-eff/webapps/ROOT/WEB-INF/classes/theme-day.properties
cat /opt/tomcat-eff/webapps/ROOT/WEB-INF/classes/theme-day.properties

NSIP=`(grep geoserver /opt/tomcat-eff/webapps/ROOT/WEB-INF/classes/theme-night.properties  |cut -d "/" -f 3 | cut -d ":" -f 1)`
sed -i "s/$NSIP/$VesselIP/" /opt/tomcat-eff/webapps/ROOT/WEB-INF/classes/theme-night.properties
cat /opt/tomcat-eff/webapps/ROOT/WEB-INF/classes/theme-night.properties && sleep 5

#echo "接口IP地址修改"

DSIP=`(sed -n 72p /opt/tomcat-eff/webapps/ROOT/WEB-INF/classes/spring/product/interface.properties | awk -F "=" '{print $2}')`
sed -i "s/$DSIP/$VesselIP/" /opt/tomcat-eff/webapps/ROOT/WEB-INF/classes/spring/product/interface.properties
sed -n 72p /opt/tomcat-eff/webapps/ROOT/WEB-INF/classes/spring/product/interface.properties
sed -n 1,2p /opt/tomcat-eff/webapps/ROOT/WEB-INF/classes/spring/product/ship.properties
Sname=`(sed -n 1p /opt/tomcat-eff/webapps/ROOT/WEB-INF/classes/spring/product/ship.properties | awk -F "=" '{print $2}')`
sed -i "s/$Sname/$Vesselname/" /opt/tomcat-eff/webapps/ROOT/WEB-INF/classes/spring/product/ship.properties
#echo "修改能效船端名称如下"
sed -n 1,2p /opt/tomcat-eff/webapps/ROOT/WEB-INF/classes/spring/product/ship.properties && sleep 2
echo "气象配置如下"
MSoldName=`(grep Extend%20V2 /opt/BINECDIS/Public/Config/MSeaConfig.ini | awk -F "=" '{ print $2 }')`
MSoldIp=`(grep Extend%20V3 /opt/BINECDIS/Public/Config/MSeaConfig.ini | awk -F "=" '{ print $2 }')`
sed -i "s/$MSoldName/$Vesselname/" /opt/BINECDIS/Public/Config/MSeaConfig.ini 
sed -i "s/$MSoldIp/$VesselIP":8080"/" /opt/BINECDIS/Public/Config/MSeaConfig.ini
MSUIP=`(sed -n 4616p /opt/BINECDIS/Public/Config/MSeaSensor.ini | awk -F "=" '{ print $2 }')`
MSTIP=`(sed -n 4617p /opt/BINECDIS/Public/Config/MSeaSensor.ini | awk -F "=" '{ print $2 }')`
sed -i "s/$MSUIP/$VesselIP/" /opt/BINECDIS/Public/Config/MSeaSensor.ini && sleep 2
sed -i "s/$MSTIP/$VesselIP/" /opt/BINECDIS/Public/Config/MSeaSensor.ini && sleep 2
#cat -n /opt/BINECDIS/Public/Config/MSeaSensor.ini | grep 4616
grep -A 1 Extend%20V2 /opt/BINECDIS/Public/Config/MSeaConfig.ini
cat -n /opt/BINECDIS/Public/Config/MSeaSensor.ini | grep -A 3  4615 && sleep 2 && echo "Sous"
echo "修改船名如下"
hostnamectl set-hostname $Vesselname && hostnamectl
echo -e "\033[36m 执行完毕后重启所有服务或重启服务器 \033[0m"
