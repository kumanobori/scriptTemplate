#!/bin/bash

mkdir -p "$(cd $(dirname $0); pwd)/output"
mkdir -p "$(cd $(dirname $0); pwd)/log"

# --------------------------------------
# �v���W�F�N�g���ƂɈقȂ�T�[�o�����i�[
# --------------------------------------

# �ڑ����ϐ�
# �擪����A  �ڑ����ʖ� �z�X�g       �|�[�g���[�U��        �閧��
SSH_PROD_STEP="prod_step 192.168.1.1     22 $CONF_USER_NAME $CONF_SSH_KEY_PATH"
SSH_PROD_WEB1="prod_web1 127.0.0.1    10101 $CONF_USER_NAME $CONF_SSH_KEY_PATH"
SSH_PROD_WEB2="prod_web2 127.0.0.1    10102 $CONF_USER_NAME $CONF_SSH_KEY_PATH"

# -----------------------
# �����̐ڑ������擾
# -----------------------
function sshProdWebAll {
	echo "${SSH_PROD_WEB1}"
	echo "${SSH_PROD_WEB2}"
}

# -----------------------
# �|�[�g�t�H���[�h�J�n
# -----------------------
function portForwardStart {
	# $1=���[�J���|�[�g�ԍ� $2=�]����A�h���X $3=�]����|�[�g�ԍ� $4=���ݑ�A�h���X $5=���ݑ䃆�[�U�� $6=���ݑ�L�[�p�X
	evalInfo "ssh -N -f -i $6 -L $1:$2:$3 $5@$4" 'DRYRUN'
}
function portForwardProdWeb1 {
	portForwardStart "10101" "web1" "22" "192.168.1.1" "$CONF_USER_NAME" "$CONF_SSH_KEY_PATH"
}
function portForwardProdWeb2 {
	portForwardStart "10102" "web2" "22" "192.168.1.1" "$CONF_USER_NAME" "$CONF_SSH_KEY_PATH"
}
# -----------------------
# �|�[�g�t�H���[�h�𕡐��J�n
# -----------------------
function portForwardProdAll {
	portForwardProdWeb1
	portForwardProdWeb2
}

# -----------------------
# �|�[�g�t�H���[�h�̏I��
# windows git bash �̏ꍇ��ps�R�}���h�̏o�͂������Ⴄ�̂ŁA���̑Ή��Ƃ��ĕ��򂵂Ă���
# -----------------------
function portForwardExit {
	if [ "${IS_WINDOWS_GIT_BASH}" = 'TRUE' ]; then
		evalInfo "ps aux |grep -v 'grep'                               |grep '/usr/bin/ssh' | awk '{ print \"kill -9\", \$1 }' | sh" 'DRYRUN'
	else
		evalInfo "ps aux |grep -v 'grep' |grep -E "^${CONF_USER_NAME}" | grep 'ssh -N'      | awk '{ print \"kill -9\", \$2 }' | sh" 'DRYRUN'
	fi
	evalDebug 'ps aux |grep ssh'
}
