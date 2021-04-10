#!/bin/bash

mkdir -p "$(cd $(dirname $0); pwd)/output"
mkdir -p "$(cd $(dirname $0); pwd)/log"

# --------------------------------------
# プロジェクトごとに異なるサーバ情報を格納
# --------------------------------------

# 接続情報変数
# 先頭から、  接続識別名 ホスト       ポートユーザ名        秘密鍵
SSH_PROD_STEP="prod_step 192.168.1.1     22 $CONF_USER_NAME $CONF_SSH_KEY_PATH"
SSH_PROD_WEB1="prod_web1 127.0.0.1    10101 $CONF_USER_NAME $CONF_SSH_KEY_PATH"
SSH_PROD_WEB2="prod_web2 127.0.0.1    10102 $CONF_USER_NAME $CONF_SSH_KEY_PATH"

# -----------------------
# 複数の接続情報を取得
# -----------------------
function sshProdWebAll {
	echo "${SSH_PROD_WEB1}"
	echo "${SSH_PROD_WEB2}"
}

# -----------------------
# ポートフォワード開始
# -----------------------
function portForwardStart {
	# $1=ローカルポート番号 $2=転送先アドレス $3=転送先ポート番号 $4=踏み台アドレス $5=踏み台ユーザ名 $6=踏み台キーパス
	evalInfo "ssh -N -f -i $6 -L $1:$2:$3 $5@$4" 'DRYRUN'
}
function portForwardProdWeb1 {
	portForwardStart "10101" "web1" "22" "192.168.1.1" "$CONF_USER_NAME" "$CONF_SSH_KEY_PATH"
}
function portForwardProdWeb2 {
	portForwardStart "10102" "web2" "22" "192.168.1.1" "$CONF_USER_NAME" "$CONF_SSH_KEY_PATH"
}
# -----------------------
# ポートフォワードを複数開始
# -----------------------
function portForwardProdAll {
	portForwardProdWeb1
	portForwardProdWeb2
}

# -----------------------
# ポートフォワードの終了
# windows git bash の場合はpsコマンドの出力が少し違うので、その対応として分岐している
# -----------------------
function portForwardExit {
	if [ "${IS_WINDOWS_GIT_BASH}" = 'TRUE' ]; then
		evalInfo "ps aux |grep -v 'grep'                               |grep '/usr/bin/ssh' | awk '{ print \"kill -9\", \$1 }' | sh" 'DRYRUN'
	else
		evalInfo "ps aux |grep -v 'grep' |grep -E "^${CONF_USER_NAME}" | grep 'ssh -N'      | awk '{ print \"kill -9\", \$2 }' | sh" 'DRYRUN'
	fi
	evalDebug 'ps aux |grep ssh'
}
