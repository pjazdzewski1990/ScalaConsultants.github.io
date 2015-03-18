#!/bin/bash

spellcheck() {
  echo "spellcheck"
}

goto() {
  echo "goto $1"
  git checkout $1
}

merge() {
  echo "merge $1 to master"
  git merge $1
}

cleanup() {
  echo "cleanup"
  rm -r _site/*
  rm -r tags/*
}

generate() {
  echo "generate"
  jekyll build
}

copy() {
  echo "copy"
  cp -r _site/tags/* tags/
}

commit() {
  echo "commit - $1"
  git add tags/
  git commit -m "$1"
}

push() {
  git push origin master
}

echo "Go Go Power Rangers"
echo "Starting Deploy in $PWD"
echo "Deploying for $1"

spellcheck
goto "master"
merge $1
cleanup
generate
copy
commit "Tags for $1"
push

echo "Post $1 was deployed. It should be visible soon"
