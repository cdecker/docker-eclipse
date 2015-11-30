FROM ubuntu:latest
RUN apt-get update;\
	apt-get install -y \
		build-essential \
		libtool \
		autotools-dev \
		autoconf \
		ccache \
		pkg-config \
		libssl-dev \
		libboost-all-dev \
		wget \
		bsdmainutils \
		libqrencode-dev \
		libqt4-dev \
		libprotobuf-dev \
		protobuf-compiler \
		git-core \
		openjdk-7-jdk \
		gdb \
		libevent-dev;\
	apt-get clean;\
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /home/developer && \
    echo "developer:x:1000:1000:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:1000:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown developer:developer -R /home/developer
#RUN echo 0 > /proc/sys/kernel/yama/ptrace_scope
ENV HOME /home/developer
RUN mkdir /develop; chown -R developer:developer /develop

RUN sed 's/main$/main universe/' -i /etc/apt/sources.list && \
    apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer libxext-dev libxrender-dev libxtst-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

RUN wget http://ftp.fau.de/eclipse/technology/epp/downloads/release/mars/1/eclipse-java-mars-1-linux-gtk-x86_64.tar.gz -O /tmp/eclipse.tar.gz && \
    cd /opt/ && \
    tar -xzf /tmp/eclipse.tar.gz && \
    rm -rf /tmp/* && \
    ln -s /opt/eclipse/eclipse /usr/local/bin/

RUN wget http://mirror.switch.ch/mirror/apache/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz -O /tmp/maven.tar.gz && \
    cd /opt/ && \
    tar -xzf /tmp/maven.tar.gz && \
    rm -rf /tmp/maven.tar.gz && \
    mv /opt/apache-maven-* maven && \
    ln -s /opt/maven/bin/mvn /usr/local/bin/

# Fix the humongous buttons
ADD .gtkrc-eclipse /home/developer/
ENV SWT_GTK3=0
ENV GTK2_RC_FILES=/usr/share/themes/cdecker/gtk-2.0/gtkrc:/home/developer/.gtkrc-eclipse

USER developer
WORKDIR /develop
CMD /opt/eclipse/eclipse
