############################################################
##! @brief	实用Shell函数
##! 
##! 
##! @file	zsl.sh
##! @author	Fstone's ComMent Tool
##! @date	2016-11-22
##! @version	0.1.3
############################################################
if [ ! "$__ZSL_H__" ] ;then
__ZSL_H__="zsl.sh"
# ############################################################

##! @brief	设置 TEST 变量
##! 
##! 当含有参数 -t 时，设置 TEST 为 echo 命令
##! @author	fstone.zh@foxmail.com
##! @date	2016-11-29
function SetTEST()
{
	echo $@ | grep -q "\-t" && TEST=echo || TEST=''
}

##! @brief	高亮显示步骤
##! 
##! 
##! @param	$1 高亮第几个单词
##! @output	
##! @author	fstone.zh@foxmail.com
##! @date	2016-11-18
step=0
function HighLightStep()
{
	((step++))
	local highLightIdx=$1
	local i=2
	local msg=""
	while [ $i -le $# ]; do
		if [ $i -eq $highLightIdx ]; then
			msg="$msg \033[47;30m${!i}\033[0m"
		else
			msg="$msg ${!i}"
		fi
		((i++))
	done
	echo -e "$step#$msg"
}

##! @brief	检查git目录更新
##! 
##! 
##! @param	$1 目标
##! @param	$2 git url
##! @param	$3 本地目录
##! @output	
##! @author	fstone.zh@foxmail.com
##! @date	2016-11-18
function GitCheck()
{
	local name=$1
	local dir=$2
	local url=$3
	if [ "$url" != "" ];then
		if [ -d "$dir" ]; then
			HighLightStep 4 git pull $name from $url
			$TEST cd $dir && $TEST git pull && $TEST cd ..
		else
			HighLightStep 4 git clone $name from $url
			$TEST git clone $url $dir
		fi
		if [ $? -ne 0 ];then exit; fi
	else # local display
		HighLightStep 3 config $name
	fi
}

##! @brief	调用shell脚本模块文件
##! 
##! 
##! @param	$1 模块文件名
##! @param	$2 文件路径
##! @param 	$3~$# 调用参数
##! @output	脚本模块输出
##! @author	fstone.zh@foxmail.com
##! @date	2016-10-27
function Call()
{
	local dir=$1
	local module=$2
	# 脚本正确完整文件名
	if [ ! -f $module ];then
		module=${dir%/*}/$module
	fi
	# 调用脚本
	sh $module ${@:3}
}



#! @brief	通过 文件(夹)相对路径/软链接 获取完整路径
##! 
##! 
##! @param	$1 文件(夹)/软链接
##! @output	绝对路径
##! @author	Fstone's ComMent Tool
##! @date	2016-09-13
function GetFullPath()
{
	local relative=$1

	local file=${relative##*/} 
	local dir=${relative%/*}
	local link=`readlink $relative`

	local abs=""
	if [ "" != "$link" ];then 	# 链接
		abs=${link%/*}
	else  # 文件(夹)
		if [ "$dir" != "$file" ];then
			if [ "$dir" == "~" ];then
				cd
			else
				cd $dir
			fi
		else
			if [ -d $dir ];then
				cd $dir
			fi
		fi
		abs=`pwd` 	# 取得绝对路径
	fi
	echo "$abs/$file"
}


##! @brief	获取变量类型
##! 
##! 
##! @param	$1 变量值
##! @output	输出变量类型，如digit / string / bool
##! @author	fstone.zh@foxmail.com
##! @date	2016-09-27
function TypeName()
{
	local type_name="null"
	local value=$1
	case "$value" in
		\-[0-9]*|[0-9]* )
			type_name="int"
			;;
		[^\s]*)
			type_name="string"
			;;
	esac
	echo $type_name
}

##! @brief	尝试创建指定目录
##! 
##! 如果目录不存在，则创建它
##! @param	$1 目录名
##! @output	
##! @author	fstone.zh@foxmail.com
##! @date	2016-10-17
function TryMakeDir()
{
	if [ ! -d "$1"  ];then
		mkdir $1
	fi
}


##! @brief	查找替换行
##! 
##! 在文件中查找模式串所在行，并替换此行内容，输出所在行
##! @param	$1 文件
##! @param	$2 模式串
##! @param	$3 替换内容
##! @output	输出行号
##! @author	fstone.zh@foxmail.com
##! @date	2016-10-18
function FindReplaceLine()
{
	file=$1
	pattern=$2
	replace=$3
	lineContent=`grep -n "$pattern" "$file"`
	if [ "$lineContent" ];then
		local lineNum=${lineContent%%:*}
		sed -i $lineNum"c $replace" $file
		echo $lineNum:$file
	# else
		# lineNum=`sed -n '$=' $file` 	# 最大行号
		# sed -i $lineNum"a $replace" $file
	fi
}

##! @brief	查找前设置带前缀行的行
##! 
##! 查找具有pattern的行n，从第n行开始进行替换（替换内容由$3-${!#}提供）；如果未找到，则在文件尾添加替换内容行
##! @param	$1 文件
##! @param	$2 pattern行
##! @param	$3~${n+2} 替换pattern后面n行内容
##! @output	输出行号
##! @author	fstone.zh@foxmail.com
##! @date	2016-10-19
function FindSetLines()
{
	local file=$1
	local pattern=$2

	local i=3
	local replace
	while [ $i -le $# ];do
		replace[ ${#replace[@]} ]="${!i}"
		((i++))
	done

	local lineContent
	local maxLineNum
	if [ -f "$file" ];then
		lineContent=`grep -n "$pattern" $file` 	# 查找 pattern
		maxLineNum=`sed -n '$=' $file` 	# 最大行号
	fi

	local lineNum
	if [ "$lineContent" ];then 		# 找到 pattern
		lineNum=${lineContent%%:*} 	# pattern 所在行号
		i=0
		while [ $i -lt ${#replace[@]} ];do
			if [ $((lineNum+i)) -le $maxLineNum ];then
				sed -i $((lineNum+i))"c ${replace[(i)]}" $file
			else
				sed -i $((lineNum+i-1))"a ${replace[(i)]}" $file
			fi
			((i++))
		done
	else # 未找到 pattern，在文件尾插入 pattern行 和 替换内容行
		if [ ! $maxLineNum ];then
			echo >> $file
			maxLineNum=1
		fi
		lineNum=$maxLineNum
		i=0
		while [ $i -lt ${#replace[@]} ];do
			sed -i $((lineNum+i))"a ${replace[(i)]}" $file
			((i++))
		done
	fi
	# echo $lineNum:$file
}

##! @brief	获取当前时间
##! 
##! 
##! @output 	标准秒数（自UTC 时间 1970-01-01 00:00:00 以来所经过的秒数） 当前纳秒数
##! @author	fstone.zh@foxmail.com
##! @date	2016-10-26
function TimeNow()
{
	local ns=`date +%N | awk '{printf "%d", $1}'`
	local s=`date +%s  | awk '{printf "%d", $1}'`
	echo $s $ns
}

##! @brief	纳秒转毫秒，舍去不足1ms部分
##! 
##! 
##! @param	$1 	纳秒数
##! @output	毫秒数 "%03d"
##! @author	fstone.zh@foxmail.com
##! @date	2016-10-26
function TimeNS2MS()
{
	local ns=$1
	local MEGA=`echo | awk '{printf "%d\n", 1e6}'`
	local ms=0
	if [ $ns ];then
		((ms=ns/MEGA))
	fi
	echo $ms | awk '{printf "%03d", $1}'

}

##! @brief	将时间格式化为 HH:MM::HH.ms 形式
##! 
##! 
##! @param	$1 秒
##! @param	$2 纳秒
##! @output	
##! @author	fstone.zh@foxmail.com
##! @date	2016-10-26
function TimeFormat()
{
	local s=$1
	local ms=`TimeNS2MS $2`
	local tm=`date -d "@$s" +%H:%M:%S`
	if [ $ms ];then
		tm+=.$ms
	fi
	echo $tm
}

##! @brief	得到指定格式的日期
##! 
##! 
##! @param	$1 日期
##! @param 	$2 指定格式 同date命令 +%Y-%m-%d
##! @output	
##! @author	fstone.zh@foxmail.com
##! @date	2016-11-09
function DateFormat()
{
	local day=$1
	day=`echo $day | sed 's/-//g' | sed 's/\///g'`
	local yy=`date +%Y`
	local mm=`date +%m`
	local dd=`date +%d`
	local format=${@:2}
	if [ "$format" = "" ]; then
		format="+%Y-%m-%d"
	fi
	if [ "int" != `TypeName $day` ];then
		day=""
	fi
	# echo today is $yy.$mm.$dd, day=$day.
	case ${#day} in
		0);;
		1) dd=0$day;;
		2) dd=$day;;
		3)
			mm=0${day:0:1}
			dd=${day:1};;
		4)
			mm=${day:0:2}
			dd=${day:2};;
		5)
			yy=${yy:0:3}${day:0:1}
			mm=${day:1:2}
			dd=${day:3};;
		6)
			yy=${yy:0:2}${day:0:2}
			mm=${day:2:2}
			dd=${day:4};;
		8)
			yy=${day:0:4}
			mm=${day:4:2}
			dd=${day:6};;
	esac
	format_date=`date -d $yy-$mm-$dd $format`
	if [ $? -eq 0 ] ; then
		echo $format_date
	else
		echo
	fi
}

##! @brief	计算时间差
##! 
##! 
##! @param	$1 	开始时间：秒
##! @param	$2 	开始时间：纳秒
##! @param	$3 	结束时间：秒
##! @param	$4 	结束时间：纳秒
##! @output	时间差 (时:分:秒.毫秒)
##! @author	fstone.zh@foxmail.com
##! @date	2016-10-26
function TimeDiff()
{
	local start_s=$1 	# 开始：秒
	local start_ns=$2 	# 开始：纳秒(10^-9秒)
	local end_s=$3 	# 结束：秒
	local end_ns=$4 	# 结束：纳秒
	# echo $start_s:$start_ns,  $end_s:$end_ns
	# 时间差
	local diff_s=
	local diff_ns=
	((diff_s=end_s-start_s))
	((diff_ns=end_ns-start_ns))
	# 纳秒借位1s
	local GIGA=`echo | awk '{printf "%d\n", 1e9}'`
	if [ $diff_ns -lt 0 ];then
		((diff_s-=1))
		((diff_ns+=GIGA))
	fi
	# 时间格式
	(( diff_s+=-28800 ))
	TimeFormat $diff_s $diff_ns
}

##! @brief	格式化输出时间差
##! 
##! 
##! @param	$1 开始：秒
##! @param	$2 开始：纳秒
##! @param	$3 结束：秒
##! @param	$4 结束：纳秒
##! @output	
##! @author	fstone.zh@foxmail.com
##! @date	2016-10-26
function TimeElapsed()
{
	local start=`TimeFormat $1 $2`
	local end=`TimeFormat $3 $4`
	local diff=`TimeDiff $1 $2 $3 $4`
	local day=`date +%m-%d`
	echo "$day ( $start ~ $end ) time elapsed $diff"
}

##! @brief	查找svn版本号
##! 
##! 
##! @param	$1 查找方式 0通过版本号; 1通过查最近30条日志
##! @param	$2 日期/版本号
##! @param	$3 目录（可选）
##! @output	
##! @author	fstone.zh@foxmail.com
##! @date	2016-11-10
function FindRevision()
{
	local mode=$1 # 查找方式
	local day=$2 # 日期/版本号
	local dir=$3  # 目录

	# 指定日期查找
	if [ "r" = "$mode" ];then
		day=`date -d "$day 1 days" +%Y-%m-%d`
		svn log $dir -r {$day} | awk 'NR==2{print $1}'
	# 从日志中过滤日期
	elif [ "l" = "$mode" ];then
		svn log $dir -l 1000 | grep $day | awk 'NR==1{print $1}'
	else
		echo
		return 1
	fi
}

##! @brief	获取指定日期的最后一个版本号
##! 
##! 
##! 
##! @param	$1 工作模式 0查询svn log -l 1000；1 svn log -r
##! @param	$2 指定日期
##! @param	$3 工作路径
##! @output	指定日期最后一个版本号;若为今天，则输出空
##! @author	fstone.zh@foxmail.com
##! @date	2016-11-09
function DayFinalRevision()
{
	local mode=$1
	local day=$2
	local dir=$3
	day=`DateFormat $day +%Y-%m-%d`
	# 不早于今天输出空,表示当前最新版本
	local today=`date +%Y-%m-%d`
	# echo $today:$day
	if [ `date -d "$day" +%s` -ge `date -d "$today" +%s` ]; then 
		echo
	else
		local i=0
		# 查找指定日期（或更早1个月内）最后的版本号
		while [ $i -lt 30 ];do
			# echo $i:$day
			local final_rev=`FindRevision $mode $day $dir`
			if [ "$final_rev" != "" ];then
				echo $final_rev
				return 0
			else # 继续向前一天查找最近更新
				day=`date -d "1 day ago $day" +%Y-%m-%d`
			fi
			((i++))
		done
	fi
	# 出错
	echo
	return 1
}

##! @brief	是否包含某个子串
##! 
##! 
##! @param	$1 模式串
##! @param 	$2 .. 字符串
##! @output	如果模式串pattern在字符串中存在，则输出pattern；否则输出空
##! @author	fstone.zh@foxmail.com
##! @date	2016-11-09
function SubOf()
{
	return  `[[ ${@:2} =~ $1 ]]`
}


# ############################################################
# `finclude script.sh` 命令
# 运行 "sh zsl.sh setup_finclude_cmd" 安装 finclude 命令
# 之后可以使用 `finclude file_or_path file.sh`
# 来引用file_or_path目录下或者与file_or_path同目录的 file.sh 脚本文件
# ############################################################
# start of finclude 命令实现
((__START_INC__=$LINENO+3))
function install_finclude()
{
#!/usr/bin/bash
# 定义 finclude 命令

ERR_CMD="echo err: need a filename to be included!"
ERR_DIR="echo err: not a directory"
ERR_FILE="echo err: not a file"

# 逐个解析参数
while [ $# -gt 0 ];do
	while getopts ":T" opt; do
		case $opt in
			T)
				TEST=echo
				;;
			?)
				;;
		esac
		shift && ((OPTIND--))
	done
	if [ $# -gt 0 ];then
		inc_para[ ${#inc_para[@]} ]=$1
		shift
	fi
done

# 第一个参数是链接
link=`readlink ${inc_para[0]}`
if [ "" != "$link" ];then
	if [ "${link:0:1}" = '/' ];then
		inc_para[0]=$link
	else
		inc_para[0]=${inc_para[0]%/*}$link
	fi
fi

case ${#inc_para[@]} in
	0) # 无参数，命令写错
		$TEST echo $ERR_CMD
		$TEST exit 1;;
	1) # 一个参数，文件路径
		inc_file=${inc_para[0]}
		# 不包含目录符号，表示当前目录下文件，须要添加 ./ 目录
		if [[ ! "$inc_file" =~ '/' ]] && [[ ! "$inc_file" =~ '\' ]];then
			inc_dir='./'
		fi;;
	?) # '>=两个参数，$1 路径 / 可提供路径的文件; $2 第一个参数指定路径下的文件; $3 ~ $# 调用$2文件的参数'
		inc_dir=${inc_para[0]}
		inc_file=${inc_para[1]}
		# '$1 不以目录符号 / or \ 结尾，可能是目录，也可能是文件：修复其目录符号'
		if [ "${inc_dir:0-1}" != '/' ] && [ "${inc_dir:0-1}" != '\' ];then
			# '如果存在目录:追加目录符号'
			if [ -d ${inc_dir} ];then
				inc_dir="$inc_dir/"
			# 如果存在文件:
			elif [ -f ${inc_dir} ];then
				# 不包含目录符号的文件：指示当前目录 
				if [[ ! "$inc_dir" =~ '/' ]] && [[ ! "$inc_dir" =~ '\' ]];then
					inc_dir='./'
				else # 包含目录符号的文件：去掉文件名，获取其所在目录
					inc_dir="${inc_dir%/*}/"
				fi
			# 不是目录，也不是文件：报目录错误
			else 
				$TEST echo $ERR_DIR path\($inc_dir\)
				$TEST exit 0
			fi
		# 以目录符号结尾, 但目录不存在：报目录错误
		elif [ ! -d "$inc_dir" ];then
			$TEST echo $ERR_DIR dir\($inc_dir\)
		fi
		;;
esac
# 如果文件不存在：报文件错
if [ ! -f "$inc_dir$inc_file" ];then
	$TEST echo $ERR_FILE $inc_dir$inc_file
else
	$TEST echo . $inc_dir$inc_file ${@:3}
fi
}
((__END_INC__=$LINENO-2))
if [ "$1" == "setup_finclude_cmd" ];then
	inc_cmd="finclude"
	inc_cmd_file=${PATH%%:*}/$inc_cmd
	mkdir -p ${inc_cmd_file%/*}
	((inc_code_line_cnt=__END_INC__-__START_INC__+1))
	head -n $__END_INC__ $0 | tail -n $inc_code_line_cnt > $inc_cmd_file
	chmod +x $inc_cmd_file
fi
# end of finclude 命令实现
# ############################################################





# ############################################################
fi #__ZSL_H__
