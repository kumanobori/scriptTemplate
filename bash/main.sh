#!/bin/bash

function help() {
	echo '概要：'
	echo '詳細：'
	echo '前提：'
	echo '引数：'
}



function init() {
	logInfo 'init start.'
	
	logError "$START_TIMESTAMP"
	logWarn "$START_YMD_HMS"
	logInfo "$START_YMD_HM"
	logDebug "$START_YMD"
	
	logInfo 'init term.'
	return 0
}

function main() {
	logInfo 'main start.'
	
	cat "${SCRIPT_DIR}/input.txt" | while read line
	do
		IFS=','
		items=(${line})
		unset IFS
		logDebug '-------------'
		# logDebug ${line}
		# logDebug ${items[0]}
		# logDebug ${items[1]}
		# logDebug ${items[2]}
		detail ${items[0]} ${items[1]} ${items[2]}
	done
	
	
	logInfo 'main term.'
	return 0
}

function detail() {
	ARG1="$1"
	ARG2="$2"
	ARG3="$3"
	logDebug "detail: ${ARG1} ${ARG2} ${ARG3}"
}

# -----------------------------------
# ----- バッチ共通前処理 START -----
# -----------------------------------
. ./common.sh

# ログレベル設定
LOG_LEVEL=${LOG_LEVEL_DEBUG}
# ログファイル設定
SCRIPT_DIR=$(cd $(dirname $0); pwd)
LOG_DIR=${SCRIPT_DIR}/log
mkdir -p ${LOG_DIR}
LOG_FILE="${START_YMD_HMS}.log"
LOGPATH=${LOG_DIR}/${LOG_FILE}
logInfo "LOGPATH=${LOGPATH}"

# 引数チェック
if [ $# -ne 0 ]; then
	echo '引数は0個でなければいけません。'
	help
	exit 1
fi


# 処理開始
logInfo 'start.'

init
INIT_RESULT=$?
if [ ${INIT_RESULT} -ne 0 ]; then
	logError "init failed. error code = ${INIT_RESULT}"
fi

main
MAIN_RESULT=$?
if [ ${MAIN_RESULT} -ne 0 ]; then
	logError "main failed. error code = ${MAIN_RESULT}"
fi

logInfo 'term.'
exit 0

# -----------------------------------
# ----- バッチ共通前処理 END -----
# -----------------------------------


