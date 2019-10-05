#!/bin/bash
# 
# スクリプト概要：
# 
# スクリプト詳細：
# 
# 前提： 
# 
# 引数：
# 

cd `dirname $0`
. ./common.sh

logInfo 'start.'

# 引数個数チェック
if [ $# -ne 0 ]; then
	echo '引数は0個でなければいけません。'
	exit 1
fi

function init() {
	logError "$START_TIMESTAMP"
	logError "$START_YMDHMS"
	logWarn "$START_YMDHM"
	logDebug "$START_YMD"
	return 0
}

init
INIT_RESULT=$?
if [ ${INIT_RESULT} -ne 0 ]; then
	logError "init failed. error code = ${INIT_RESULT}"
fi

logInfo 'term.'
exit 0
