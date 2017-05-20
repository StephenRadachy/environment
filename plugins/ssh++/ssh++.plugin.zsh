export SSH_KEY_PATH="${HOME}/.ssh/"

eval `ssh-agent -s > /dev/null`

ssh-load(){
	ssh-add "$SSH_KEY_PATH$1"
}

ssh-create(){
	if test -f "$SSH_KEY_PATH$1"; then
		echo "ssh key $1 exists; please choose another name."
	else 
		ssh-keygen -b 4096 -t rsa -f "$SSH_KEY_PATH$1" -C "$(whoami)"
	fi
}

ssh-ls(){
	ls -h ~/.ssh | awk '!/(.pub|^authorized_keys|^config|^known_hosts)$/'
}