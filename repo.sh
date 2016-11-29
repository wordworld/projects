#!/bin/bash
if [ -f "zsl.sh" ];then
	bash zsl.sh setup_finclude_cmd
fi
if [ $? -ne 0 ];then exit; fi

`finclude $0 zsl.sh`
SetTEST $@

cdir=`GetFullPath $0`
cdir=${cdir%/*}
basedir=$cdir/..

function AddRepo()
{
	repo_name[${#repo_name[@]}]=$1
	repo_dir[${#repo_dir[@]}]=$2
	repo_url[${#repo_url[@]}]=$3

}

mygit="https://github.com/wordworld"

common=("common" "$basedir/common" "$mygit/common")
AddRepo ${common[@]}

zip=("zip" "$basedir/zip" "$mygit/zip")
AddRepo ${zip[@]}

fvimSuits=("fvimSuits" "$basedir/fvimSuits" "$mygit/fvimSuits")
AddRepo ${fvimSuits[@]}

repo_mgr=("repo_mgr" "$basedir/repo_mgr" "$mygit/repo_mgr")
AddRepo ${repo_mgr[@]}
