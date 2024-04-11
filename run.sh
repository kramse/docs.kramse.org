#! /bin/sh

# Build and transfer the Jekyll site

# While writing
bundle exec jekyll serve &
bundle exec jekyll build --watch &

# build and save site
#bundle exec jekyll build

# Moved to seperate script
# scp -r _site/* cheese01:/home/hlk/docs.kramse.org
