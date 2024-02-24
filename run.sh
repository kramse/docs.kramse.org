#! /bin/sh

# Build and transfer the Jekyll site

#bundle exec jekyll serve &
#bundle exec jekyll build --watch &

# build and save site
#bundle exec jekyll build

scp -r _site/* cheese01:/home/hlk/docs.kramse.org
