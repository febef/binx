#!/bin/bash

echo -ne "Pulling."

root=`pwd`
changes=0

mkdir -p $(get_repos_dir) || true

for repodata in $(get_repos); do

  rama=`get_rama $repodata`
  repo=`get_repo $repodata`
  project=`get_project_name $repodata`  
  rname=`get_repo_name ${repo}`
  rdir=`get_repos_dir ${project} ${rname}`

  cd "$root/$rdir/$rname"
  
  sout=`git fetch --all 2> /dev/null`;
  echo $sout | grep 'Counting'
  fetch=$?  

  if ( 
    [ `git branch | grep '*' | sed 's;*\s;;'` !=  $rama ] 
  ); then
    git checkout $rama 2>&1 > /dev/null
  fi
  
  git status | grep -E 'behind|ahead' > /dev/null
  status="$?"

  if [ "$fetch" == "0" ] || [ "$status" == "0" ]; then

    currentCommitId=`git rev-parse HEAD`

    #changes=`git diff $rama origin/$rama` | grep 'diff'
    #if [ "$?" == "0" ]; then
    
      changes=1
    
      echo -ne "» $rname [$rama] \n"
      
      git merge
      newCommitId=`git rev-parse HEAD`
      git shortlog $currentCommitId...$newCommitId
   #else
   # echo "→"
   #fi
  else
   echo -ne "."
  fi

  cd $root
done

if [ $changes == 0 ]; then
  echo -ne " No changes! "
fi
echo "Done."

