############################################
# source this file in your ~/.bash_profile #
############################################


# Adds git auto-completion to the terminal
# This has to go before the PS1 so that the __git_ps1 command is available
source /usr/local/git/contrib/completion/git-completion.bash
source /usr/local/git/contrib/completion/git-prompt.sh

# Customize Prompt
################
BLACK="\[\e[0;30m\]"
BLUE="\[\e[0;34m\]"
GREEN="\[\e[0;32m\]"
CYAN="\[\e[0;36m\]"
RED="\[\e[0;31m\]"
PURPLE="\[\e[0;35m\]"
BROWN="\[\e[0;33m\]"
GREY="\[\e[0;37m\]"
YELLOW="\[\e[0;33m\]"
WHITE="\[\e[0;37m\]"

B_BLUE="\[\e[1;34m\]"
B_GREEN="\[\e[1;32m\]"
B_CYAN="\[\e[1;36m\]"
B_RED="\[\e[1;31m\]"
B_PURPLE="\[\e[1;35m\]"
B_BROWN="\[\e[1;33m\]"
B_GREY="\[\e[1;37m\]"
B_YELLOW="\[\e[1;33m\]"
B_WHITE="\[\e[1;37m\]"

PS1="$B_PURPLE>> $B_YELLOW[\#] $B_CYAN\A : $B_YELLOW\W$B_WHITE\$(__git_ps1) $B_CYAN:: $GREEN"
######################################


# Add current directory name to window/tab title
export PROMPT_COMMAND='echo -ne "\033]0;${PWD##*/}\007"'



# Fix for stupid Java bug that was causing all java processes to make a dock icon and steal focus
# (the second answer)
# http://stackoverflow.com/questions/10627405/how-to-set-java-system-properties-globally-on-os-x
export _JAVA_OPTIONS=-Djava.awt.headless=true

# Make an alias for up a directory
alias ..='cd ..'


# Protobuf 2.4.1 for CDH 4.5.x+ and Protobuf 2.5.0 for CDH 5.x+
# Probobuf 2.4.1 should be the installed one so it works for older CDH 4.x
export HADOOP_PROTOC_CDH5_PATH=/Users/rkanter/dev/protobuf/protobuf-2.5.0/build/bin/protoc
export HADOOP_PROTOC_CDH4_PATH=/Users/rkanter/dev/protobuf/protobuf-2.4.1/build/bin/protoc
# For upstream
export HADOOP_PROTOC_PATH=$HADOOP_PROTOC_CDH5_PATH


# Determine where Java is and set env var
export JAVA_HOME=`/usr/libexec/java_home -v 1.7`
# For Hadoop, also need to put the above in .bashrc file


# Switch between Java versions
# /usr/libexec/java_home -v 1.X will always point to the latest 1.X version
java6() {
	export JAVA_HOME=`/usr/libexec/java_home -v 1.6` && `java -version`
}
java7() {
	export JAVA_HOME=`/usr/libexec/java_home -v 1.7` && `java -version`
}
java8() {
    export JAVA_HOME=`/usr/libexec/java_home -v 1.8` && `java -version`
}


# Give Maven more heap and permgen memory so it won't run out
export MAVEN_OPTS="-Xmx1024m -XX:MaxPermSize=512m"

# To build Oozie
alias mvnOozie='mvn clean package assembly:single -DskipTests'
# To build Hadoop (mr2)
alias mvnHadoop='mvn clean package -Pdist -Dtar -Dmaven.javadoc.skip=true -DskipTests'
# To build Hadoop (mr1)
alias antHadoop='ant jar -Dreactor.repo=file:///dev/null'

# findbugs needs to be installed ('brew install findbugs')
export FINDBUGS_HOME=/usr/local/Cellar/findbugs/3.0.0/libexec


# I make this typo a lot
alias opne='open'

# Import SVN and GIT functions
# BASH_SOURCE gets you the directory of this script (usually)
# http://stackoverflow.com/questions/192292/bash-how-best-to-include-other-scripts/12694189#12694189
currentDir="${BASH_SOURCE%/*}"
source $currentDir/vcs_functions.sh

# Grep for trailing whitespace
alias grepTrailingWhitespace='grep "^+.*[[:space:]]$" -n'

# Print out lines longer than 132 characters starting with a '+' character
# Useful for finding out which lines are too long for Oozie in a patch
alias tooLongOozie='sed -n "/^+.\{133\}/p"'

# Print out lines longer than 80 characters starting with a '+' character
# Useful for finding out which lines are too long for Hadoop in a patch
alias tooLongHadoop='sed -n "/^+.\{81\}/p"'

# untar a file
alias untar='tar -zxvf'

# add txt extension to add files in current dir
alias addtxt='for x in `ls`; do mv $x $x.txt; done'

# Run jstack against the currently running maven process and filter for 'Test' and 'oozie' to get an idea of what the currently running test is
alias jstackMaven='jstack `jps | grep surefirebooter | cut -f 1 -d " "`'
alias jstackMavenTest='jstackMaven | grep Test | grep oozie'

