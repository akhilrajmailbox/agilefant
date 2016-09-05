from ubuntu:14.04
maintainer akhil raj


run apt-get update
run echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
run apt-get install -y python-software-properties software-properties-common 
run add-apt-repository -y ppa:webupd8team/java
run apt-get -y update
run apt-get install -y oracle-java7-installer tomcat7 tomcat7-user ttf-dejavu unzip nano git


# Workaround for https://bugs.launchpad.net/ubuntu/+source/tomcat7/+bug/1232258
run ln -s /var/lib/tomcat7/common/ /usr/share/tomcat7/common
run ln -s /var/lib/tomcat7/server/ /usr/share/tomcat7/server
run ln -s /var/lib/tomcat7/shared/ /usr/share/tomcat7/shared


workdir /tmp/af
run git clone -b agilefant https://github.com/akhilrajmailbox/agilefant.git


run rm -rf /var/lib/tomcat7/webapps/ROOT/*
run cp -r /tmp/af/agilefant/* /var/lib/tomcat7/webapps/ROOT/


workdir /var/lib/tomcat7/webapps/ROOT/WEB-INF
run sed -i -e"s/localhost/192.168.1.234/" agilefant.conf 
run sed -i -e"s/\/agilefant/\/agilefant/" agilefant.conf
run sed -i -e"s/username = \"agilefant\"/username = \"agilefant\"/" agilefant.conf
run sed -i -e"s/password = \"agilefant\"/password = \"agilefant\"/" agilefant.conf


run echo JAVA_HOME="/usr/lib/jvm/java-7-oracle" >> /etc/environment
run . /etc/environment

#Create a temp directory at /usr/share/tomcat7/skel
run mkdir /usr/share/tomcat7/skel/temp

#Tell Tomcat7 where is my conf/server.xml located
run export CATALINA_BASE=/usr/share/tomcat7/skel

expose 8080
entrypoint service tomcat7 start || tail -f /var/log/apt/history.log && bash
# entrypoint use || instead of && ( tomcat service fail while start but running thats why i used ||.if tomcat is running use && )
