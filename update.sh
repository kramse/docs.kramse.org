#! /bin/sh

# Transfer the Jekyll site

scp -r _site/* cheese01:/home/hlk/docs.kramse.org
