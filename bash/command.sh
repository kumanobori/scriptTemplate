#!/bin/bash

function help() {
	echo '------------------------------------------------------------------------'
	echo '概要：複数サーバにコマンドを実行する。'
	echo '-d 指定すると、dryrun実行する。この場合、sshポートフォワードとファイルの取得は行わない。'
	echo '-s 対象サーバを指定する。必須。複数指定時はカンマで区切る。'
	echo '   ps=prod-step p1=prod-web1 p2=prod-web2'
	echo '   pw=prod-web全て'
	echo '-l ログファイル名を指定する。省略した場合は${YMD_YMS}_command.log。'
	echo '-x 実行するコマンド。必須。'
	echo '------------------------------------------------------------------------'
}


function setSshArgs2() {
	
	SERVERS="$(echo ${SERVERS} | sed -e 's/,/\n/g')"
	
	# 対象サーバ取得
	TARGETS=''
	TARGETS="${TARGETS}`getValueIfKeyExists "${SERVERS}" 'ps' "$SSH_PROD_STEP\n"`"
	TARGETS="${TARGETS}`getValueIfKeyExists "${SERVERS}" 'pw|p1' "$SSH_PROD_WEB1\n"`"
	TARGETS="${TARGETS}`getValueIfKeyExists "${SERVERS}" 'pw|p2' "$SSH_PROD_WEB2\n"`"
	
	# 対象サーバに基づいてPortForward設定
	doFuncIfKeyExists "${TARGETS}" 'prod_web1' 'portForwardProdWeb1'
	doFuncIfKeyExists "${TARGETS}" 'prod_web2' 'portForwardProdWeb2'
	
	echo -e ${TARGETS} | while read line
	do
		logDebug '-------------------------------'
		items=(${line})
		logInfo "SERVER=${line}"
		setSshArgs1 ${items[0]} ${items[1]} ${items[2]}
	done

	portForwardExit
}

function setSshArgs1 {
	execSsh "${CONF_SSH_KEY_PATH}" "$3" "${CONF_USER_NAME}" "$2" "${REMOTE_COMMAND}"
}

function execSsh() {
	local SSH_KEY_PATH=$1
	local SERVER_PORT=$2
	local SSH_USER_NAME=$3
	local SERVER_IP=$4
	local REMOTE_COMMAND=$5
	
	CMD="ssh -n -i ${SSH_KEY_PATH} -p ${SERVER_PORT} ${SSH_USER_NAME}@${SERVER_IP} \"${REMOTE_COMMAND}\""
	evalInfo "${CMD}" 'DRYRUN'
}


# -------------------------
# 処理開始
# -------------------------

# パラメータ取得
while getopts ds:l:x: OPT
do
	case $OPT in
		"d" ) IS_DRYRUN="TRUE" ;;
		"s" ) IS_SERVERS="TRUE" ; SERVERS="$OPTARG" ;;
		"l" ) IS_LOG="TRUE" ; LOGFILE="$OPTARG" ;;
		"x" ) IS_CMD="TRUE" ; REMOTE_COMMAND="$OPTARG" ;;
	esac
done

echo "IS_DRYRUN=$IS_DRYRUN, IS_CMD=$IS_CMD, IS_SERVERS=$IS_SERVERS"
# パラメータチェック
if [ "${IS_CMD}" != 'TRUE' -o "${IS_SERVERS}" != 'TRUE' ]; then
	echo '-s, -xは必須です。'
	help
	exit
fi

# 共通スクリプト読み込み
. ./common.sh
. ./common_pj.sh
. ./common_pjconf.sh

# ログファイル定義
if [ "${LOGFILE}" = '' ]; then
	LOGFILE="${START_YMD_HMS}_command.log"
fi

LOGPATH="$(cd $(dirname $0); pwd)/log/${LOGFILE}"
logInfo "======================"
logInfo "sendCommand.sh start."
logInfo "LOGPATH=${LOGPATH}"

logInfo "IS_DRYRUN=${IS_DRYRUN}, SERVERS=${SERVERS}, REMOTE_COMMAND=${REMOTE_COMMAND}"

# メイン実行
setSshArgs2

