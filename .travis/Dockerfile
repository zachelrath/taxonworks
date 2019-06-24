FROM ubuntu:16.04

RUN apt-get update \
&&  apt-get install -y curl \
&&  curl -sL https://deb.nodesource.com/setup_10.x | bash - \
&&  apt-get install wget \
&&  echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' >> /etc/apt/sources.list.d/pgdg.list \
&&  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt-get update && \
    apt-get install -y locales \
                       libgeos-dev libproj-dev postgresql-10-postgis-2.4 postgresql-10-postgis-2.4-scripts \
                       build-essential nodejs gnupg2 git sudo libgtk-3-0 libgtk-3-dev libdbus-glib-1-2 \
                       gawk autoconf automake bison libffi-dev libgdbm-dev libncurses5-dev libsqlite3-dev \
                       libtool libyaml-dev pkg-config sqlite3 zlib1g-dev libgmp-dev libreadline6-dev libssl-dev \
                       imagemagick libmagickcore-dev libmagickwand-dev libpq-dev libproj-dev libgeos-dev libgeos++-dev \
&& apt-get clean \
&& locale-gen en_US.UTF-8 \
&& rm -rf /var/lip/abpt/lists/* /tmp/* /var/tmp/*

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Switch to unprivileged user
ARG UID
ARG GID
RUN groupadd -g $GID -o travis
RUN useradd -m -u $UID -g $GID -G sudo -o -s /bin/bash travis
RUN echo "travis ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER travis
ENV HOME /home/travis
WORKDIR $HOME

ENV FIREFOX_SOURCE_URL 'https://download.mozilla.org/?product=firefox-latest&lang=en-US&os=linux64'
RUN mkdir firefox-latest \
&&  wget --no-verbose -O firefox-latest/firefox-latest.tar.bz2 $FIREFOX_SOURCE_URL \
&&  cd firefox-latest \
&&  tar -xf firefox-latest.tar.bz2

ENV PATH $HOME/firefox-latest/firefox:$PATH
RUN firefox --version

# Install node-sass
RUN npm rebuild node-sass

# Install RVM
RUN gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -L get.rvm.io | bash -s stable

RUN echo 'gem: --no-rdoc --no-ri >> "$HOME/.gemrc"'

RUN mkdir ./app
WORKDIR ./app

# Install Ruby
ARG RUBY_VERSION
ARG BUNDLER_VERSION
SHELL ["/bin/bash", "-l", "-c"]
RUN rvm install $RUBY_VERSION \
&&  rvm use $RUBY_VERSION --default \
&&  gem install bundler --no-ri --no-rdoc -v $BUNDLER_VERSION

# Install node packages
COPY package.json .
COPY package-lock.json .
RUN npm install

# Install gems
COPY Gemfile .
COPY Gemfile.lock .
RUN  bundle install --without development production

CMD ["/bin/bash", "-l"]
