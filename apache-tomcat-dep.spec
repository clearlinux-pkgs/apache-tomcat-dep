Name     : apache-tomcat-dep
Version  : 9.0.20
Release  : 2
URL      : https://repo.maven.apache.org
Summary  : No detailed summary available
Group    : Development/Tools
License  : Apache-2.0

Source0 : http://www.apache.org/dyn/closer.lua?action=download&filename=/tomcat/tomcat-connectors/native/1.2.21/source/tomcat-native-1.2.21-src.tar.gz
Source1 : http://www.apache.org/dyn/closer.lua?action=download&filename=/commons/daemon/source/commons-daemon-1.1.0-native-src.tar.gz
Source2 : http://www.apache.org/dyn/closer.lua?action=download&filename=/commons/daemon/binaries/commons-daemon-1.1.0-bin.tar.gz
Source3 : http://archive.eclipse.org/eclipse/downloads/drops4/R-4.10-201812060815/ecj-4.10.jar
Source4 : https://repo.maven.apache.org/maven2/javax/xml/soap/saaj-api/1.3.5/saaj-api-1.3.5.jar
Source5 : https://repo.maven.apache.org/maven2/geronimo-spec/geronimo-spec-jaxrpc/1.1-rc4/geronimo-spec-jaxrpc-1.1-rc4.jar
Source6 : https://repo.maven.apache.org/maven2/wsdl4j/wsdl4j/1.6.3/wsdl4j-1.6.3.jar
Source7 : https://repo.maven.apache.org/maven2/biz/aQute/bnd/biz.aQute.bnd/4.0.0/biz.aQute.bnd-4.0.0.jar
Source8 : https://repo.maven.apache.org/maven2/biz/aQute/bnd/biz.aQute.bndlib/4.0.0/biz.aQute.bndlib-4.0.0.jar

%description
## Welcome to Apache Tomcat!
### What Is It?
The Apache TomcatÂ® software is an open source implementation of the Java
Servlet, JavaServer Pages, Java Expression Language and Java WebSocket
technologies. The Java Servlet, JavaServer Pages, Java Expression Language and
Java WebSocket specifications are developed under the
[Java Community Process](https://jcp.org/en/introduction/overview).

%prep

%build

%install
# Create the dependencies jar files
mkdir -p  %{buildroot}/usr/share/apache-tomcat
cp %{SOURCE0} %{buildroot}/usr/share/apache-tomcat/
cp %{SOURCE1} %{buildroot}/usr/share/apache-tomcat/
cp %{SOURCE2} %{buildroot}/usr/share/apache-tomcat/
cp %{SOURCE3} %{buildroot}/usr/share/apache-tomcat/
cp %{SOURCE4} %{buildroot}/usr/share/apache-tomcat/
cp %{SOURCE5} %{buildroot}/usr/share/apache-tomcat/
cp %{SOURCE6} %{buildroot}/usr/share/apache-tomcat/
cp %{SOURCE7} %{buildroot}/usr/share/apache-tomcat/
cp %{SOURCE8} %{buildroot}/usr/share/apache-tomcat/

%files
%defattr(-,root,root,-)
/usr/share/apache-tomcat/tomcat-native-1.2.21-src.tar.gz
/usr/share/apache-tomcat/commons-daemon-1.1.0-native-src.tar.gz
/usr/share/apache-tomcat/commons-daemon-1.1.0-bin.tar.gz
/usr/share/apache-tomcat/ecj-4.10.jar
/usr/share/apache-tomcat/saaj-api-1.3.5.jar
/usr/share/apache-tomcat/geronimo-spec-jaxrpc-1.1-rc4.jar
/usr/share/apache-tomcat/wsdl4j-1.6.3.jar
/usr/share/apache-tomcat/biz.aQute.bnd-4.0.0.jar
/usr/share/apache-tomcat/biz.aQute.bndlib-4.0.0.jar
