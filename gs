#!/bin/bash

root=`pwd`
changes=0

mkdir -p $(get_repos_dir) || true

for repodata in $(get_repos); do

  repo=`get_repo $repodata`
  rama=`get_rama $repodata`
  rname=`get_repo_name ${repo}`
  rdir=`get_repos_dir`

  cd "$root/$rdir/$rname"
  

  if ( 
    [ `git branch | grep '*' | sed 's;*\s;;'` !=  $rama ] 
  ); then
    git checkout $rama 2>&1 > /dev/null
  fi
  
  sout=`git status 2> /dev/null`;

  echo $sout | grep -E 'ahead|behind' > /dev/null
  if [ "$?" == "0" ]; then
    changes=1
    echo -en "» $rname [$rama] : "
    echo -en "$sout" | grep 'by' \
      | sed 's;(use "git push" to publish your local commits);;g' \
      | sed 's;(use "git pull" to update your local branch);;g' \
      | sed 's;nothing to commit, working tree clean;;g' ;
  fi

  cd $root
done

if [ $changes == 0 ]; then
  echo -ne " No changes! "
fi
echo "Done."

