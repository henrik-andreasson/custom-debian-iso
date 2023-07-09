#!/bin/bash


while getopts j:r:s:f: flag; do
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
  if [ -f "$repos/$reponame/$repoversion/Packages" -o -f "$repos/$reponame/$repoversion/Packages.gz"  ] ; then
    echo "adding repo: $reponame $repoversion"
    rsync --verbose --progress --recursive "$repos/$reponame/$repoversion/" "$dest/repo-$reponame-$repoversion/" >&2

    # TODO: work around for problems getting our gpg key into the iso
    rm -rf "$dest/repo-$reponame-$repoversion/Release.gpg" "$dest/repo-$reponame-$repoversion/InRelease"

  else
    echo "repo ${reponame}/${repoversion} has no Packages(.gz)"
  fi
done
/bin/echo  "done."
