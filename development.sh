#!/usr/bin/env bash

if ! [ $# -eq 4 ]; then
  echo "ERROR: number of parameters"
  echo "USAGE: development.sh [init | finish] <develop_type> <develop_id> <project_home>"
  exit 1
fi

cd $4

# current Git branch
branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

# establish branch and tag name variables
devBranch=develop
developBranch=$2-$3

echo "**********************************"
echo "Operation: development $1 $2"
echo "Project: $4"
echo "Id: $3"
echo "Current git branch: $branch"
echo "Development branch: $developBranch"
echo "**********************************"



if [ "$1" = "init" ]; then

	exists=$(git show-ref refs/tags/$developBranch)
	if  [ -n "$exists" ]; then
		echo "ERROR: Develop $developBranch already exists"
		exit 1
	fi

	# create the development branch from the -develop branch
	echo "Create the branch $developBranch from $devBranch"
	git checkout -b $developBranch $devBranch

else 
if [ "$1" = "finish" ]; then
	
	exists=$(git show-ref refs/heads/$developBranch)
	if ! [ -n "$exists" ]; then
		echo "ERROR: Branch $developBranch not exists"
		exit 1
	fi

	# merge development branch into develop
	echo "Merge development branch $developBranch into $devBranch"
	git checkout $devBranch
	git merge --no-ff -m "Development $developBranch" $developBranch

	# create tag for new development from -develop
	git tag $developBranch

	# remove development branch
	echo "Remove development branch $developBranch"
	git branch -d $developBranch	

else
	echo "ERROR: bad operation"
	echo "USAGE: development.sh [init | finish] <develop_type> <develop_id> <project_home>"
	exit 1
fi
fi