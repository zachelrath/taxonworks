#!/bin/bash
set -e

export TW_PATH=$(git rev-parse --show-toplevel)

cd $TW_PATH

sed -i -e 's/^\s*spec\s*$//' .dockerignore
echo "spec/fixtures/vcr_cassettes" >> .dockerignore

cp Gemfile Gemfile.lock package.json package-lock.json .travis

TW_BUILD_ARGS="\
  --build-arg UID=$(id -u) --build-arg GID=$(id -g) \
  --build-arg RUBY_VERSION=$(cat Gemfile | grep -e "^ruby\s*.*$" | sed -E "s/[^']*'([^']*)'/ruby-\1/") \
  --build-arg BUNDLER_VERSION=$(tail -n1 Gemfile.lock | tr -d '[:space:]')"

docker build --target tw-travis-base -t tw-travis-base .travis $TW_BUILD_ARGS
docker build -t tw-travis -f .travis/Dockerfile . $TW_BUILD_ARGS

rm .travis/Gemfile .travis/Gemfile.lock .travis/package.json .travis/package-lock.json
git checkout .dockerignore

mkdir -p $TW_PATH/public/packs-test
mkdir -p $TW_PATH/public/assets
mkdir -p $TW_PATH/tmp/cache/webpacker

DOCKER_ARGS='-d \
  --env TEST_WORKER=$TEST_WORKER --env TEST_WORKERS=5 --env RAILS_ENV=test \
      -v "$TMP_PATH/spec/fixtures/vcr_cassettes":/home/travis/app/spec/fixtures/vcr_cassettes \
      -v "$TW_PATH/public/packs-test":/home/travis/app/public/packs-test \
      -v "$TW_PATH/public/assets":/home/travis/app/public/assets \
      -v "$TW_PATH/tmp/cache":/home/travis/app/tmp/cache \
'

# Build assets first
export TEST_WORKER=no
export TMP_PATH=/tmp
eval "docker run $DOCKER_ARGS --name tw_container tw-travis"
docker exec -it tw_container bash -l -c "bundle exec rake assets:precompile"
docker rm -f tw_container

for TEST_WORKER in `seq 0 4`; do
  export TMP_PATH=/tmp/tw_test_worker_$TEST_WORKER

  mkdir -p $TMP_PATH/spec/fixtures/vcr_cassettes

  eval "docker run $DOCKER_ARGS --name tw_container_$TEST_WORKER tw-travis"

  until docker exec -it tw_container_$TEST_WORKER sudo -u postgres psql -c \
    'CREATE ROLE travis SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN;'; \
  do sleep 1; done
done

CMDS='\
echo ===[TEST_WORKER=$TEST_WORKER before_script $(date -u +%Y%m%d-%H%M%S)]=== \
&& docker exec -it tw_container_$TEST_WORKER bash -l -c "bundle exec rake db:create" \
&& docker exec -it tw_container_$TEST_WORKER bash -l -c "bundle exec rake db:migrate" \
&& docker exec -it tw_container_$TEST_WORKER bash -l -c ".travis/spec_runner.sh"; \
docker rm -f tw_container_$TEST_WORKER; while true; do sleep 86400; done \
'

tmux new-session "\
      export TEST_WORKER=0
      $CMDS" \; \
    split-window "\
      export TEST_WORKER=1
      $CMDS" \; \
    split-window "\
      export TEST_WORKER=2
      $CMDS" \; \
    split-window "\
      export TEST_WORKER=3
      $CMDS" \; \
    split-window "\
      export TEST_WORKER=4
      $CMDS" \; \
    select-layout even-vertical
