#!/bin/bash
# --------------------------------------------------------
# - 概要：バッチ開始日時文字列の生成と、ログ用関数の定義。
# - 前提：各関数を呼び出すまでに、呼び出し元で変数${LOGPATH}が指定されること
# --------------------------------------------------------

# 日付変数
START_TIMESTAMP="$(date "+%Y%m%d%H%M%S")"
START_YMD_HMS="${START_TIMESTAMP:0:8}_${START_TIMESTAMP:8:6}"
START_YMD_HM="${START_TIMESTAMP:0:8}_${START_TIMESTAMP:8:4}"
START_YMD="${START_TIMESTAMP:0:8}"

# ログレベル
# デフォルトは全レベル出力。
# レベルを変更する場合は、このスクリプトを呼んだあとで、呼び出し側スクリプトでLOG_LEVELを上書きする。
LOG_LEVEL=0
LOG_LEVEL_TRACE=1
LOG_LEVEL_DEBUG=2
LOG_LEVEL_INFO=3
LOG_LEVEL_WARN=4
LOG_LEVEL_ERROR=5
LOG_LEVEL_NONE=6

# ログ出力関数
# $1=ログ文字列 $2=ログレベルを表す数値 $3=ログレベルを表す文字列
function log() {
	if [ "${LOG_LEVEL}" -le "$2" ]; then
		local TIMESTAMP="$(date "+%Y%m%d-%H%M%S")"
		local LOG="${TIMESTAMP} [${3}] ${1}"
		echo -e "${LOG}" >> ${LOGPATH} 2>&1
		echo -e "${LOG}"
	fi
}
function logError() {
	log "$1" "${LOG_LEVEL_ERROR}" "ERROR"
}
function logWarn() {
	log "$1" "${LOG_LEVEL_WARN}" "WARN"
}
function logInfo() {
	log "$1" "${LOG_LEVEL_INFO}" "INFO"
}
function logDebug() {
	log "$1" "${LOG_LEVEL_DEBUG}" "DEBUG"
}
function logTrace() {
	log "$1" "${LOG_LEVEL_TRACE}" "TRACE"
}

# コマンドをログ出力＋実行する関数
# $1=コマンド文字列 $2=DRYRUN指定 $3=ログ出力関数名 $4=基準ログレベル
function doEval() {
	if [ "${LOG_LEVEL}" -le "$4" ]; then
		if [ "${IS_DRYRUN}" = 'TRUE' -a "$2" = 'DRYRUN' ]; then
			echo `$3 command:"$1 (DRYRUN, not executed)"`
		else
			echo `$3 command:"$1"`
			eval "$1" >> ${LOGPATH} 2>&1
		fi
	fi
}
# $1：コマンド文字列
# $2：'DRYRUN'を指定すると、DRYRUNモードであれば実行しない。
function evalError() {
	doEval "$1" "$2" 'logError' "${LOG_LEVEL_ERROR}"
}
function evalWarn() {
	doEval "$1" "$2" 'logWarn' "${LOG_LEVEL_WARN}"
}
function evalInfo() {
	doEval "$1" "$2" 'logInfo' "${LOG_LEVEL_INFO}"
}
function evalDebug() {
	doEval "$1" "$2" 'logDebug' "${LOG_LEVEL_DEBUG}"
}
function evalTrace() {
	doEval "$1" "$2" 'logTrace' "${LOG_LEVEL_TRACE}"
}

# 検索対象文字列に対象行があった場合のみValueを返す
# $1=検索対象文字列(複数行) $2=検索対象条件(正規表現) $3=返すValue
function getValueIfKeyExists {
	echo -e "$1" | while read line
	do
		local hit=$(echo $line | grep -E "$2" | wc -l)
		if [ "$hit" -ge 1 ]; then
			echo "$3"
			return 0
		fi
	done
}

# 検索対象文字列に対象行があった場合のみFunctionを実行する
# $1=検索対象文字列(複数行) $2=検索対象条件(正規表現) $3=実行するFunction
function doFuncIfKeyExists {
	echo -e "$1" | while read line
	do
		local hit=$(echo $line | grep -E "$2" | wc -l)
		if [ "$hit" -ge 1 ]; then
			echo `$3`
			return 0
		fi
	done
}
