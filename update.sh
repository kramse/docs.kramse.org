#! /bin/sh

# First make sure we push the latest changes into Git
# Git must always contain the source for the published version

# Transfer the Jekyll site
git push && scp -r _site/* cheese01:/home/hlk/garden.kramse.org
