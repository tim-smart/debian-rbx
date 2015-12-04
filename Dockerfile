FROM philcryer/min-jessie

ENV RUBINIUS_VERSION="2.5.8" \
    LC_ALL="en_US.UTF-8" \
    LANG="en_US.UTF-8" \
    PATH="/usr/local/rubinius/bin:/usr/local/rubinius/gems/bin:$PATH"

RUN apt-get update && \
    PACKAGES="locales \
        libedit2 \
        libyaml-0-2 \
        openssl" && \
    BUILD_PACKAGES="build-essential \
        curl \
        bison \
        ruby-dev \
        bundler \
        rake \
        zlib1g-dev \
        libyaml-dev \
        libssl-dev \
        libreadline-dev \
        libncurses5-dev \
        llvm-dev \
        libeditline-dev \
        libedit-dev" && \
# install packages
    apt-get install -y --no-install-recommends $PACKAGES $BUILD_PACKAGES && \
# install locales
    locale > /etc/default/locale && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure -f noninteractive locales && \
    locale-gen --purge $LANG && \
# download rubinius source
    cd /usr/src && \
    curl -LO https://github.com/rubinius/rubinius/releases/download/v$RUBINIUS_VERSION/rubinius-$RUBINIUS_VERSION.tar.bz2 && \
    tar -xjf rubinius-$RUBINIUS_VERSION.tar.bz2 && \
    cd rubinius-$RUBINIUS_VERSION && \
# compile
    bundle install && \
    ./configure --prefix=/usr/local/rubinius && \
    rake install && \
# Clean up
    SUDO_FORCE_REMOVE=yes apt-get purge --auto-remove -y $BUILD_PACKAGES && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /usr/src/* \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /var/lib/gems
