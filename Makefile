SHELL=/usr/bin/env sh

.PHONY: run

run:
	bundle exec jekyll serve --trace --future #--verbose

deploy: build upload

clean:
	bundle exec jekyll clean --trace

build: clean
	bundle exec jekyll build --trace
	tree _site -C -d | sed 's/^/                    /'

install:
	bundle config set --local path '.vendor/bundle'
	bundle install

update:
	bundle update --all
	bundle update --bundler
	bundle install

