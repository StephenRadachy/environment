# export go env to environment
eval "export $(go env | sed 's/"/\\"/g' | xargs | sed 's/\" /\"; export /g')"
export GOPATH="$HOME/Code"
export PATH="$PATH:$GOPATH/bin"