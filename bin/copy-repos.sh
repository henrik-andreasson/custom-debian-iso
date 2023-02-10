#!/bin/bash


while getopts j:r:s: flag; do
  case $flag in
    j) jsonconfig="$OPTARG";
      ;;
    r) repos=$OPTARG;
      ;;
    s) server=$OPTARG;
        ;;
    ?)
      exit;
      ;;
  esac
done

if [ "x$jsonconfig" != "x" ] ; then
  repojson="$jsonconfig"
else
  repojson=repos.json
fi

if [ "x$server" != "x" ] ; then
  dest="$server"
else
  dest="server"
fi


if [ "x$repos" == "x" ] ; then
  repos="repos"
fi

mapfile -t reponames < <(jq -r 'keys[]' $repojson)

/bin/echo -n "Removing old repos..."
rm -rf "$dest/repo-*"
echo "done."

/bin/echo -n "Updating the repos on the iso..."

for reponame in "${reponames[@]}" ; do
  repoversion=$(jq ."$reponame" $repojson | tr -d '"')
  if [ -f "$repos/$reponame/$repoversion/Packages" -o "$repos/$reponame/$repoversion/Packages.gz"  ] ; then
    echo "repo: $reponame $repoversion"
    rsync --verbose --progress --recursive "$repos/$reponame/$repoversion/" "$dest/repo-$reponame-$repoversion/"
  else
    echo "repo has no Packages(.gz)"
  fi
done
/bin/echo  "done."
