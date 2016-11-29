#!/bin/bash
. ./repo.sh

repo_dir=("${common[1]}" "${zip[1]}" "${fvimSuits[1]}" "${repo_mgr[1]}")
cd ..

i=0
while [ $i -lt ${#repo_dir[@]} ];do
	cd ${repo_dir[(i)]} && echo -e "----------\n ${repo_dir[(i)]}\n----------" && git status && cd ..
	((i++))
done
