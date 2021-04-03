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
LOG_LEVEL=0
LOG_LEVEL_DEBUG=1
LOG_LEVEL_INFO=2
LOG_LEVEL_WARN=3
LOG_LEVEL_ERROR=4
LOG_LEVEL_NONE=5

# ログ出力関数
function log() {
	local TIMESTAMP="$(date "+%Y%m%d-%H%M%S")"
	local LOG="${TIMESTAMP} ${1} ${2}"
	echo "${LOG}" >> ${LOGPATH}
	echo "${LOG}"
}
function logError() {
	if [ "${LOG_LEVEL}" -le "${LOG_LEVEL_ERROR}" ]; then
		echo "$(log "[ERROR]" "$1")"
	fi
}
function logWarn() {
	if [ "${LOG_LEVEL}" -le "${LOG_LEVEL_WARN}" ]; then
		echo "$(log "[WARN] " "$1")"
	fi
}
function logInfo() {
	if [ "${LOG_LEVEL}" -le "${LOG_LEVEL_INFO}" ]; then
		echo "$(log "[INFO] " "$1")"
	fi
}
function logDebug() {
	if [ "${LOG_LEVEL}" -le "${LOG_LEVEL_DEBUG}" ]; then
		echo "$(log "[DEBUG]" "$1")"
	fi
}

# コマンドをログ出力＋実行する関数
# 実行結果はログレベルにかかわらず出力する。
function doEval() {
	eval $1 >> ${LOGPATH} 2>&1
}
function evalError() {
	logError "command: $1"
	doEval "$1"
}
function evalWarn() {
	logWarn "command: $1"
	doEval "$1"
}
function evalInfo() {
	logInfo "command: $1"
	doEval "$1"
}
function evalDebug() {
	logDebug "command: $1"
	doEval "$1"
}

