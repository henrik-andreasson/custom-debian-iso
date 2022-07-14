#!/bin/bash

if [ "x$1" != "x" ] ; then
  repojson="$1"
else
  repojson=repos.json
fi

if [ "x$2" != "x" ] ; then
  dest="$2"
else
  dest="server"
fi

mapfile -t reponames < <(jq -r 'keys[]' $repojson)

/bin/echo -n "Removing old repos..."
rm -rf "$dest/repo-*"
echo "done."

/bin/echo -n "Updating the repos on the iso..."

for reponame in "${reponames[@]}" ; do
  repoversion=$(jq ."$reponame" $repojson | tr -d '"')
  echo "repo: $reponame $repoversion"
  rsync --verbose --progress --recursive "repos/$reponame/$repoversion/" "$dest/repo-$reponame-$repoversion/"
done
/bin/echo  "done."
