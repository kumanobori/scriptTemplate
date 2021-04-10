#!/bin/bash

function help() {
	echo '------------------------------------------------------------------------'
	echo '概要：複数サーバから指定したファイルを集める'
	echo '-d 指定すると、dryrun実行する。この場合、sshポートフォワードとファイルの取得は行わない。'
	echo '-s 対象サーバを指定する。必須。複数指定時はカンマで区切る。'
	echo '   ps=prod-step p1=prod-web1 p2=prod-web2'
	echo '   pw=prod-web全て'
	echo '-l ログファイル名を指定する。省略した場合は${YMD_YMS}_fetch.log。'
	echo '-f 取得するファイルのパス。必須。'
	echo '------------------------------------------------------------------------'
}


function setScpArgs2() {
	logDebug "setScpArgs2"
	
	SERVERS="$(echo ${SERVERS} | sed -e 's/,/\n/g')"
	
	# 対象サーバ取得
	TARGETS=''
	TARGETS="${TARGETS}`getValueIfKeyExists "${SERVERS}" 'ps' "$SSH_PROD_STEP\n"`"
	TARGETS="${TARGETS}`getValueIfKeyExists "${SERVERS}" 'pw|p1' "$SSH_PROD_WEB1\n"`"
	TARGETS="${TARGETS}`getValueIfKeyExists "${SERVERS}" 'pw|p2' "$SSH_PROD_WEB2\n"`"
	
	# 対象サーバに基づいてPortForward設定
	doFuncIfKeyExists "${TARGETS}" 'prod_web1' 'portForwardProdWeb1'
	doFuncIfKeyExists "${TARGETS}" 'prod_web2' 'portForwardProdWeb2'
	
	local DIR_PATH=$( echo ${FILE_PATH} | sed -E 's:^(.+)/([^/]+)$:\1:')
	local FILE_NAME=$(echo ${FILE_PATH} | sed -E 's:^(.+)/([^/]+)$:\2:')
	logInfo "setScpArgs2: DIRPATH=${DIR_PATH}, FILENAME=${FILE_NAME}"

	echo -e "${TARGETS}" | while read line
	do
		logDebug '----------------------------------------'
		items=(${line})
		logInfo "SERVER=${line}"
		setScpArgs1 ${items[0]} ${items[1]} ${items[2]} ${DIR_PATH} ${FILE_NAME}
	done

	portForwardExit
}

function setScpArgs1() {
	local ARG_SERVER_NAME=$1
	local ARG_SERVER_IP=$2
	local ARG_SERVER_PORT=$3
	local ARG_REMOTE_DIR_PATH=$4
	local ARG_FILE_NAME=$5
	
	
	local HAS_DOT=$(echo ${ARG_FILE_NAME} | grep \\. | wc -l)
	logTrace "HAS_DOT=${HAS_DOT}"
	if [ ${HAS_DOT} -ne 0 ]; then
		logTrace '.あり'
		local LOCAL_FILE_NAME=$(echo ${ARG_FILE_NAME} | sed -E "s:(\..+)$:_${ARG_SERVER_NAME}\1:")
	else
		logTrace '.なし'
		local LOCAL_FILE_NAME=${ARG_FILE_NAME}_${ARG_SERVER_NAME}
	fi
	logInfo "LOCAL_FILE_NAME=${LOCAL_FILE_NAME}"
	
	local a1=${CONF_SSH_KEY_PATH}
	local a2=${ARG_SERVER_PORT}
	local a3=${CONF_USER_NAME}
	local a4=${ARG_SERVER_IP}
	local a5=${ARG_REMOTE_DIR_PATH}/${ARG_FILE_NAME}
	local a6="$(cd $(dirname $0); pwd)/output/${LOCAL_FILE_NAME}"
	logTrace "a6=${a6}"
	
	logTrace "$a1" "$a2" "$a3" "$a4" "$a5" "$a6"
	execScp "$a1" "$a2" "$a3" "$a4" "$a5" "$a6"
}

function execScp() {
	local SSH_KEY_PATH=$1
	local SERVER_PORT=$2
	local SSH_USER_NAME=$3
	local SERVER_IP=$4
	local REMOTE_FILE_PATH=$5
	local LOCAL_FILE_PATH=$6
	
	CMD="scp -C -i ${SSH_KEY_PATH} -P ${SERVER_PORT} ${SSH_USER_NAME}@${SERVER_IP}:${REMOTE_FILE_PATH} ${LOCAL_FILE_PATH}"
	
	evalInfo "${CMD}" DRYRUN
}


# -------------------------
# 処理開始
# -------------------------

# パラメータ取得
while getopts ds:l:f: OPT
do
	case $OPT in
		"d" ) IS_DRYRUN="TRUE" ;;
		"s" ) IS_SERVERS="TRUE" ; SERVERS="$OPTARG" ;;
		"l" ) IS_LOG="TRUE" ; LOGFILE="$OPTARG" ;;
		"f" ) FLG_F="TRUE" ; FILE_PATH="$OPTARG" ;;
	esac
done

echo "IS_DRYRUN=$IS_DRYRUN, FLG_F=$FLG_F, IS_SERVERS=$IS_SERVERS, SERVERS=$SERVERS, -f=${FILE_PATH}"
echo "IS_LOG=${IS_LOG}, LOGFILE=${LOGFILE}"


# パラメータチェック
if [ "${IS_SERVERS}" != 'TRUE' ] ; then
	echo '-sは須です。'
	help
	exit
fi
if [ "${FLG_F}" != 'TRUE' ] ; then
	echo '-fは必須です。'
	help
	exit
fi

# 共通スクリプト読み込み
. ./common.sh
. ./common_pj.sh
. ./common_pjconf.sh

# ログ定義
if [ "${LOGFILE}" = '' ]; then
	LOGFILE="${START_YMD_HMS}_fetch.log"
fi
LOG_LEVEL=${LOG_LEVEL_DEBUG}


LOGPATH="$(cd $(dirname $0); pwd)/log/${LOGFILE}"
logDebug "========================"
logInfo "fetch.sh start."
logInfo "LOGPATH=${LOGPATH}"

# メイン実行
setScpArgs2

