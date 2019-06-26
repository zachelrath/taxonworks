FROM ubuntu:16.04 AS tw-travis-base

RUN apt-get update \
&&  apt-get install -y curl \
&&  curl -sL https://deb.nodesource.com/setup_10.x | bash - \
&&  echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' >> /etc/apt/sources.list.d/pgdg.list \
&&  curl -sL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt-get update && \
    apt-get install -y locales \
                       libgeos-dev libproj-dev postgresql-10-postgis-2.4 postgresql-10-postgis-2.4-scripts \
                       build-essential nodejs gnupg2 git sudo libgtk-3-0 libgtk-3-dev libdbus-glib-1-2 \
                       gawk autoconf automake bison libffi-dev libgdbm-dev libncurses5-dev libsqlite3-dev \
                       libtool libyaml-dev pkg-config sqlite3 zlib1g-dev libgmp-dev libreadline6-dev libssl-dev \
                       imagemagick libmagickcore-dev libmagickwand-dev libpq-dev libproj-dev libgeos-dev libgeos++-dev \
&& apt-get clean \
&& locale-gen en_US.UTF-8 \
&& rm -rf /var/lip/abpt/lists/* /tmp/* /var/tmp/* \
&& sed -i.bak 's/local\s*all\s*all\s*peer/local all all trust/' /etc/postgresql/10/main/pg_hba.conf

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Switch to unprivileged user
ARG UID
ARG GID
RUN groupadd -g $GID -o travis \
&& useradd -m -u $UID -g $GID -G sudo -o -s /bin/bash travis \
&& echo "travis ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER travis
ENV HOME /home/travis
WORKDIR $HOME

RUN mkdir firefox-latest \
&&  cd firefox-latest \
&&  curl -sL 'https://download.mozilla.org/?product=firefox-latest&lang=en-US&os=linux64' | \
    tar -xjf - \
&&  curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version 1.7.0 \
&&  gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
&&  curl -L get.rvm.io | bash -s stable \
&&  echo 'gem: --no-rdoc --no-ri >> "$HOME/.gemrc"' \
&&  npm rebuild node-sass

ENV PATH $HOME/.yarn/bin:$HOME/firefox-latest/firefox:$PATH

RUN firefox --version

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

FROM tw-travis-base AS tw-travis

# Copy complete repo
COPY --chown=travis:travis . .

# Set up
RUN cp config/application_settings.yml.travis config/application_settings.yml \
&&  cp config/database.yml.travis config/database.yml \
&&  cp config/secrets.yml.example config/secrets.yml \
&&  mkdir -p tmp/downloads \
&&  mkdir -p spec/fixtures/vcr_cassettes \
&&  mkdir -p public/packs-test \
&&  mkdir -p public/assets \
&&  mkdir -p tmp/cache

CMD ["sudo", "-u", "postgres", "/usr/lib/postgresql/10/bin/postgres", "-D", "/var/lib/postgresql/10/main", "-c", "config_file=/etc/postgresql/10/main/postgresql.conf"]
