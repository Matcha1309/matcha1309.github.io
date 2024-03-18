SHELL=/usr/bin/sh

.PHONY: run

run:
	bundle exec jekyll serve --trace #--verbose

deploy: build upload

clean:
	bundle exec jekyll clean --trace

build: clean
	bundle exec jekyll build --trace
	tree _site -C -d | sed 's/^/                    /'

install:
	bundle config set --local path '.vendor/bundle'
	bundle install

upload: build
	echo Start upload
	rsync -varhIu -e "ssh -p 222" --progress --delete _site/ jan@ggu.cz:/userdata/users/jan/web/lyricall.cz/

