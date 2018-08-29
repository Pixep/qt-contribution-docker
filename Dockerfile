FROM consol/ubuntu-xfce-vnc:1.2.1
MAINTAINER Adrien Leravat <Pixep@users.noreply.github.com>

USER 0
RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils

# Install dependencies
RUN apt-get update && \
    apt-get install -y libxcb-xinerama0-dev build-essential perl python git '^libxcb.*-dev' libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev flex bison gperf libicu-dev libxslt-dev ruby libssl-dev libxcursor-dev libxcomposite-dev libxdamage-dev libxrandr-dev libdbus-1-dev libfontconfig1-dev libcap-dev libxtst-dev libpulse-dev libudev-dev libpci-dev libnss3-dev libasound2-dev libxss-dev libegl1-mesa-dev gperf bison libbz2-dev libgcrypt11-dev libdrm-dev libcups2-dev libatkmm-1.6-dev libasound2-dev libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev qt5-default

# Install tools
RUN apt-get update && \
    apt-get install -y gdb valgrind clang clang-format terminator

# Download Qt installer
RUN wget http://download.qt.io/official_releases/online_installers/qt-unified-linux-x64-online.run -P /headless/
RUN chmod +x qt-unified-linux-x64-online.run

#USER other user?
ENV HOME /headless
COPY res/bg_sakuli.png $HOME/.config/

# Clone and checkout Qt
WORKDIR $HOME
RUN git clone git://code.qt.io/qt/qt5.git qt5
WORKDIR $HOME/qt5

# Checkout branch, default to "dev"
ARG BRANCH
ENV ENV_BRANCH ${BRANCH:-dev}
RUN git checkout $ENV_BRANCH

# Use MODULE_SUBSET environment variable, and defaut to "default"
ARG MODULE_SUBSET
ENV SUBSET ${MODULE_SUBSET:-default,-qtwebkit,-qtwebkit-examples,-qtwebengine,-qtlocation,-qt3d,-qtwebengine}
# Use CODEREVIEW_USER environment variable to set flag "--codereview-username" only if needed
ARG CODEREVIEW_USER
ENV ENV_CODEREVIEW_USER ${CODEREVIEW_USER:+--codereview-username $CODEREVIEW_USER}
ARG CONFIGURE_FLAGS

# Init and configure
RUN ./init-repository --module-subset=${SUBSET} $USERNAME_FLAG
RUN ./configure -developer-build -nomake examples -nomake tests -opensource -confirm-license -prefix $PWD $CONFIGURE_FLAGS

# Build Qt
ARG MAKE_FLAGS
ENV ENV_MAKE_FLAGS ${MAKE_FLAGS:--j6}
RUN make $MAKE_FLAGS

# Qt Repo tools
WORKDIR $HOME
RUN git clone git://code.qt.io/qt/qtrepotools.git

# Configure Git for Gerrit
RUN git config --global core.autocrlf input && \
    git config --global status.showuntrackedfiles all && \
    git config --global push.default tracking && \
    git config --global rerere.enabled true && \
    git config --global rerere.autoupdate true && \
    git config --global rebase.stat true && \
    git config --global color.ui auto && \
    git config --global core.pager "less -FRSX" && \
    git config --global alias.di diff && \
    git config --global alias.ci commit && \
    git config --global alias.co checkout && \
    git config --global alias.ann blame && \
    git config --global alias.st status && \
    git config --global alias.graph 'log --all --graph --decorate --abbrev-commit'
