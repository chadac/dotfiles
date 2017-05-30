#!/bin/bash
## Oracle and OpenJDK Java 8 + Gradle

echo "Installing OpenJDK 8..."
sudo apt-get install -y openjdk-8-jre

echo "Installing Oracle Java 8..."
sudo add-apt-repository ppa:webupd8team/java -y
sudo apt-get update
sudo apt-get install -y oracle-java8-installer

## Installing Gradle only once, since it's only needed for initial
## projects (the wrapper should be used afterwards)
echo "Installing Gradle..."
wget -O /tmp/gradle-3.5.zip https://services.gradle.org/distributions/gradle-3.5-bin.zip
sudo mkdir /opt/gradle
sudo unzip -d /opt/gradle /tmp/gradle-3.5.zip

echo "Done!"
