alias cg="grt"

# open github for repo/branch in browser
gh() {
	# confirm in git repo
	git rev-parse 2>/dev/null
	if [[ $? != 0 ]]; then
		echo "Not a git repository."
		return 1
	fi

	# set remote
	if [ -n "$1" ]; then
		remote="$1"
	else
		remote="origin"
	fi

	# set branch
	if [ -z "$2" ]; then
		branch=$(git rev-parse --abbrev-ref HEAD | sed 's/#/%23/' 2>/dev/null)
	else
		branch="$2"
	fi

	# grab remote url
	remote_url="remote.${remote}.url"
	giturl=$(git config --get $remote_url)
	
	# verify remote url

	if [ -z "$giturl" ]; then
		echo "$remote_url not set."
		return 1
	fi

	# generate url
	giturl="https://$(echo "$giturl" | cut -d '@' -f 2 | sed -e 's/\.git//g' | tr ':' '/')/tree/${branch}"

	echo "opening GitURL $giturl"
	open $giturl
	return 0
}