#!/bin/bash

# 日付変数
START_TIMESTAMP="$(date "+%Y%m%d%H%M%S")"
START_YMDHMS="${START_TIMESTAMP:0:8} ${START_YMDHMS:9:6}"
START_YMDHM="${START_TIMESTAMP:0:12}"
START_YMD="${START_TIMESTAMP:0:8}"

# ログ出力用変数
LOGDIR="$(pwd)/log"
LOGFILE="${START_YMDHM}.log"
LOGPATH="${LOGDIR}/${LOGFILE}"

# ログ出力関数
function log() {
	local TIMESTAMP="$(date "+%Y%m%d-%H%M%S")"
	local LOG="${TIMESTAMP} ${1} ${2}"
	echo "${LOG}" >> ${LOGPATH}
	echo "${LOG}"
}
function logError() {
	echo "$(log "[ERROR]" "$1")"
}
function logWarn() {
	echo "$(log "[WARN] " "$1")"
}
function logInfo() {
	echo "$(log "[INFO] " "$1")"
}
function logDebug() {
	echo "$(log "[DEBUG]" "$1")"
}

