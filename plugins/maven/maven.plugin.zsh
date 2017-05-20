export M2_HOME=$(mvn --version | grep "Maven home" | cut -c 13- | sed 's/;$//')
export PATH=$PATH:$M2_HOME/bin