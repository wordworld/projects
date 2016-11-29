#!/bin/bash
if [ -f "zsl.sh" ];then
	bash zsl.sh setup_finclude_cmd
fi
if [ $? -ne 0 ];then exit; fi

`finclude $0 repo.sh`

i=0
while [ $i -lt ${#repo_name[@]} ];do
	GitCheck "${repo_name[(i)]}" "${repo_dir[(i)]}" "${repo_url[(i)]}"
	((i++))
done

