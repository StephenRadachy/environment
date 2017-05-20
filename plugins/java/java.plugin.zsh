# Set JDK
export JAVA_HOME=$(/usr/libexec/java_home)
export PATH=$PATH:${JAVA_HOME}/bin

setjdk() {
    export JAVA_HOME=$(/usr/libexec/java_home -v $1)
	export PATH=${JAVA_HOME}/bin:$PATH
}