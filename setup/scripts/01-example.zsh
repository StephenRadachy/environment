copy(){
	mv "$2/$1" "$2/$1.bak"
	cp "${0:a:h}/setup/files/$1" "$2"
}

#copy .example ${HOME}

echo "test"