#!/bin/bash

# needs jekyll, git, ssh repo clone
# sudo apt-get install aspell

# Switch to branch you want to publish
# goto the main dir
# run the script with the branch name as param

spellcheck() {
  echo "Spellcheck for $1"
  r=`find _posts/ -name "*$1*" -exec cat {} \; | aspell list`
  echo "Spell check result are $r"
  echo -n "Do you want to continue [y/n] + [ENTER]: "
  read choice
  if [ "$choice" != "y" ]
  then
    echo 'Aborting'
    exit 5
  fi
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
  echo "test"
  ### echo "push"
  ### git push origin master
}

if [ $# -lt 1 ]; then
  echo 1>&2 "$0: remember to add branch param"
  exit 2
elif [ $# -gt 1 ]; then
  echo 1>&2 "$0: too many arguments"
  exit 4
fi

echo "Go Go Power Rangers"
echo "Starting Deploy in $PWD"
echo "Deploying for $1"

spellcheck $1
goto "master"
merge $1
cleanup
generate
copy
commit "Tags for $1"
push

echo "Post $1 was deployed. It should be visible soon"
