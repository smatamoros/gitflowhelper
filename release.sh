#!/usr/bin/env bash

if ! [ $# -eq 3 ]; then
  echo "ERROR: number of parameters"
  echo "USAGE: release.sh [init | finish] <release_version> <project_home>"
  exit 1
fi

cd $3

# current Git branch
branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

# v1.0.0, v1.5.2, etc.
versionLabel=v$2

echo "**********************************"
echo "Operation: release $1"
echo "Project: $3"
echo "Version: $2"
echo "Current git branch: $branch"
echo "Version label: $versionLabel"
echo "**********************************"

# establish branch and tag name variables
devBranch=develop
masterBranch=master
releaseBranch=release-$versionLabel

if [ "$1" = "init" ]; then

	exists=$(git show-ref refs/tags/$versionLabel)
	if  [ -n "$exists" ]; then
		echo "ERROR: Release $2 already exists"
		exit 1
	fi

	# update version in gradle.properties in develop branch
	echo "Update version in gradle in $devBranch"
	git checkout $devBranch
	echo "version=$2" > gradle.properties
	# commit version number increment
	git commit -am "Update version to $2"
 
	# create the release branch from the -develop branch
	echo "Create the release branch $releaseBranch from $devBranch"
	git checkout -b $releaseBranch $devBranch	

else 
if [ "$1" = "finish" ]; then
	
	exists=$(git show-ref refs/heads/$releaseBranch)
	if ! [ -n "$exists" ]; then
		echo "ERROR: Branch $releaseBranch not exists"
		exit 1
	fi

	# merge release branch into master
	echo "Merge release branch $releaseBranch into $masterBranch"
	git checkout $masterBranch
	git merge --no-ff -m "Release $versionLabel" $releaseBranch

	# create tag for new version from -master
	git tag $versionLabel

	# merge release branch into develop
	echo "Merge release branch $releaseBranch into $devBranch"
	git checkout $devBranch
	git merge --no-ff -m "Release $versionLabel" $releaseBranch

	# remove release branch
	echo "Remove release branch $releaseBranch"
	git branch -d $releaseBranch	
	
else
	echo "ERROR: bad operation"
	echo "USAGE: release.sh [init | finish] <release_version> <project_home>"
	exit 1
fi
fi