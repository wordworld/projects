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

repos=("common" "zip" "fvimSuits" "repo_mgr" "fstoneos" "CmdMail" "lib_demo" "checkout" "smoke")

function AddRepo()
{
	local name=$1
	local mygit="https://github.com/wordworld"
	repo_name[${#repo_name[@]}]="$name"
	repo_dir[${#repo_dir[@]}]="$basedir/$name"
	repo_url[${#repo_url[@]}]="$mygit/$name"
}

for rep in ${repos[@]}; do
	AddRepo $rep
done
