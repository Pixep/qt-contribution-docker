FROM consol/ubuntu-xfce-vnc:1.2.1 as build-environment
MAINTAINER Adrien Leravat <Pixep@users.noreply.github.com>

USER 0
RUN apt-get update && \
    apt-get install -y libxcb-xinerama0-dev build-essential perl python git '^libxcb.*-dev' libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev flex bison gperf libicu-dev libxslt-dev ruby libssl-dev libxcursor-dev libxcomposite-dev libxdamage-dev libxrandr-dev libdbus-1-dev libfontconfig1-dev libcap-dev libxtst-dev libpulse-dev libudev-dev libpci-dev libnss3-dev libasound2-dev libxss-dev libegl1-mesa-dev gperf bison libbz2-dev libgcrypt11-dev libdrm-dev libcups2-dev libatkmm-1.6-dev libasound2-dev libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev qt5-default

# Download Qt installer
RUN wget http://download.qt.io/official_releases/online_installers/qt-unified-linux-x64-online.run -P /headless/

#USER other user?
RUN mkdir /root/qt-contribution
WORKDIR /root/qt-contribution

RUN git clone git://code.qt.io/qt/qt5.git
WORKDIR /root/qt-contribution/qt5
RUN git checkout dev

# Use MODULE_SUBSET environment variable, and defaut to "default"
ARG MODULE_SUBSET
ENV SUBSET ${MODULE_SUBSET:-default,-qtwebkit,-qtwebkit-examples,-qtwebengine,-qtlocation,-qt3d,-qtwebengine}

# Use CODEREVIEW_USER environment variable to set flag "--codereview-username" only if needed
ARG CODEREVIEW_USER
ENV USERNAME_FLAG ${CODEREVIEW_USER:+--codereview-username $CODEREVIEW_USER}

RUN ./init-repository --module-subset=${SUBSET} --branch $USERNAME_FLAG
RUN ./configure -developer-build -nomake examples -nomake tests -opensource -confirm-license -no-gtkstyle -prefix $PWD
RUN make -j4
