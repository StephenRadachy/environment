copy(){
	mv "$2/$1" "$2/$1.bak"
	cp "${0:a:h}/setup/files/$1" "$2"
}

copy .gitconfig ~
copy .slate ~

eval 'mkdir ~/Code 2> /dev/null'