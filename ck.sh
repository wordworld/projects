#!/usr/bin/bash
if [ -f "zsl.sh" ];then
	bash zsl.sh setup_finclude_cmd
fi
if [ $? -ne 0 ];then exit; fi

`finclude $0 repo.sh`

i=0
while [ $i -lt ${#repo_dir[@]} ];do
	cd ${repo_dir[(i)]} && echo -e "----------\n ${repo_name[(i)]}\n----------" && git status && cd ..
	((i++))
done
