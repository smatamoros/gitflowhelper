#!/usr/bin/env bash

if ! [ $# -eq 3 ]; then
  echo "ERROR: number of parameters"
  echo "USAGE: hotfix.sh [init | finish] <hotfix_version> <project_home>"
  exit 1
fi

cd $3

# current Git branch
branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

# v1.0.0, v1.5.2, etc.
versionLabel=v$2

echo "**********************************"
echo "Operation: hotfix $1"
echo "Project: $3"
echo "Version: $2"
echo "Current git branch: $branch"
echo "Version label: $versionLabel"
echo "**********************************"


# establish branch and tag name variables
devBranch=develop
masterBranch=master
hotfixBranch=hotfix-$versionLabel

if [ "$1" = "init" ]; then

	exists=$(git show-ref refs/tags/$versionLabel)
	if  [ -n "$exists" ]; then
		echo "ERROR: Hotfix $2 already exists"
		exit 1
	fi

	# update version in gradle.properties
	echo "Update version in gradle in $masterBranch"
	git checkout $masterBranch
	echo "version=$2" > gradle.properties
	# commit version number increment
	git commit -am "Update version to $2"

	# create the hotfix branch from the -master branch
	echo "Create the hotfix branch $hotfixBranch from $masterBranch"
	git checkout -b $hotfixBranch $masterBranch

else 
if [ "$1" = "finish" ]; then

	exists=$(git show-ref refs/heads/$hotfixBranch)
	if ! [ -n "$exists" ]; then
		echo "ERROR: Branch $hotfixBranch not exists"
		exit 1
	fi

	# merge hotfix branch into master
	echo "Merge hotfix branch $hotfixBranch into $masterBranch"
	git checkout $masterBranch
	git merge --no-ff -m "Hotfix $versionLabel" $hotfixBranch

	# create tag for new version from -master
	git tag $versionLabel

	# merge hotfix branch into develop
	echo "Merge hotfix branch $hotfixBranch into $devBranch"
	git checkout $devBranch
	git merge --no-ff -m "Hotfix $versionLabel" $hotfixBranch

 
	# remove hotfix branch
	echo "Remove hotfix branch $hotfixBranch"
	git branch -d $hotfixBranch	
	
else
	echo "ERROR: bad operation"
	echo "USAGE: hotfix.sh [init | finish] <release_version> <project_home>"
	exit 1
fi
fi