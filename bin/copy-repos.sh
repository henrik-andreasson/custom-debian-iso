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

for reponame in "${reponames[@]}" ; do
  repoversion=$(jq ."$reponame" $repojson | tr -d '"')
  if [ ! -d "$repos/$reponame/$repoversion" ] ; then
      echo "repo ${repos}/${reponame}/${repoversion} does not exist"
      continue
  fi
  packages_file=$(find "$repos/$reponame/$repoversion" -iname "Packages*" | head -n 1)

  if [  -f "$packages_file" ] ; then
    echo "    - adding repo: $reponame $repoversion"
    rsync --verbose --progress --recursive "$repos/$reponame/$repoversion/" "$dest/repo-$reponame-$repoversion/" >&2

    # TODO: work around for problems getting our gpg key into the iso
    rm -rf "$dest/repo-$reponame-$repoversion/Release.gpg" "$dest/repo-$reponame-$repoversion/InRelease"

  else
    echo "repo ${repos}/${reponame}/${repoversion} has no Packages(.gz)"
    ls -la "$repos/$reponame/$repoversion/"
  fi
done
