#!/bin/bash
############################################
# source this file in your ~/.bash_profile #
############################################


# Adds git auto-completion to the terminal
# This has to go before the PS1 so that the __git_ps1 command is available
# Make sure to run these two installs for them to work:
# 1. brew install git bash-completion
# 2. brew install bash-git-prompt
source /usr/local/etc/bash_completion.d/git-completion.bash
source /usr/local/etc/bash_completion.d/git-prompt.sh

# Customize Prompt
################
# shellcheck disable=SC2034
BLACK="\[\e[0;30m\]"
# shellcheck disable=SC2034
BLUE="\[\e[0;34m\]"
# shellcheck disable=SC2034
GREEN="\[\e[0;32m\]"
# shellcheck disable=SC2034
CYAN="\[\e[0;36m\]"
# shellcheck disable=SC2034
RED="\[\e[0;31m\]"
# shellcheck disable=SC2034
PURPLE="\[\e[0;35m\]"
# shellcheck disable=SC2034
BROWN="\[\e[0;33m\]"
# shellcheck disable=SC2034
GREY="\[\e[0;37m\]"
# shellcheck disable=SC2034
YELLOW="\[\e[0;33m\]"
# shellcheck disable=SC2034
WHITE="\[\e[0;37m\]"

# shellcheck disable=SC2034
B_BLUE="\[\e[1;34m\]"
# shellcheck disable=SC2034
B_GREEN="\[\e[1;32m\]"
# shellcheck disable=SC2034
B_CYAN="\[\e[1;36m\]"
# shellcheck disable=SC2034
B_RED="\[\e[1;31m\]"
# shellcheck disable=SC2034
B_PURPLE="\[\e[1;35m\]"
# shellcheck disable=SC2034
B_BROWN="\[\e[1;33m\]"
# shellcheck disable=SC2034
B_GREY="\[\e[1;37m\]"
# shellcheck disable=SC2034
B_YELLOW="\[\e[1;33m\]"
# shellcheck disable=SC2034
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
export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
# For Hadoop, also need to put the above in .bashrc file


# Switch between Java versions
# /usr/libexec/java_home -v X will always point to the latest X version
java8() {
    export JAVA_HOME=$(/usr/libexec/java_home -v 1.8 -F)
    java -version
}
java11() {
    export JAVA_HOME=$(/usr/libexec/java_home -v 11 -F)
    java -version
}
java14() {
    export JAVA_HOME=$(/usr/libexec/java_home -v 14 -F)
    java -version
}
javaList() {
    /usr/libexec/java_home -V
}

# Give Maven more heap and permgen memory so it won't run out
export MAVEN_OPTS="-Xmx2048m -XX:MaxPermSize=1024m"


# Python is a mess and it seems like each program requires a different version of Python.
# The simplest way to handle this is to use pyenv by following the instructions here:
# http://akbaribrahim.com/managing-multiple-python-versions-with-pyenv/
# Make sure to install pyenv first (brew install pyenv)
# That website lists a bunch of useful pyenv commands
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi


# To build Oozie
alias mvnOozie='mvn clean package assembly:single -DskipTests'
# To build Hadoop (mr2)
alias mvnHadoop='mvn clean package -Pdist -Dtar -Dmaven.javadoc.skip=true -DskipTests -DskipShade'
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
source "$currentDir"/vcs_functions.sh

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

# add txt extension to all files in current dir
alias addtxt='for x in $(ls); do mv $x $x.txt; done'

# Run jstack against a currently running unit test (via surefire from maven), also versions for filtering on Oozie or Hadoop
# Useful for getting a stack trace on what test is currently running and where it is
alias jstackMaven='jstack $(jps | grep surefirebooter | cut -f 1 -d " ")'
alias jstackMavenTest='jstackMaven | grep Test'
alias jstackMavenTestOozie='jstackMavenTest | grep oozie'
alias jstackMavenTestHadoop='jstackMavenTest | grep hadoop'

# Pretty print JSON
alias pjson='python -m json.tool'

# Increase history size/length
HISTSIZE=20000
HISTFILESIZE=20000


# Use this to test for flakey unit tests
mvnflakey() {
    numTimes=$1
    testName=$2

    if [[ -z "$numTimes" || -z "$testName" ]]; then
      echo "usage: mvnflakey <numTimes> <testName> [additional args for mvn]"
      return -1
    fi

    shift
    shift
    for ((n=1; n<=numTimes; n++))
    do
		echo "Starting run ${n}"
        mvn test -Dtest="${testName}" "$@"
        if [ $? -ne 0 ]; then
            echo "Failure after $((n-1)) runs"
            return -1
		else
			echo "Run ${n} was a success"
		fi
    done
}


# Use this to upload to multiple GCE servers
# For example: uploadToGCE rkanter-z 3 file.txt /tmp/
uploadToGCE() {
	hostPrefix=$1
	numHosts=$2
	sourcePath=$3
	destinationPath=$4

    if [[ -z "$hostPrefix" || -z "$numHosts" || -z "$sourcePath" || -z "$destinationPath" ]]; then
      echo "usage: uploadToGCE <hostPrefix> <numHosts> <sourcePath> <destinationPath>"
      return -1
    fi

    for ((n=1; n<=numHosts; n++))
    do
		target="$hostPrefix-$n.gce.cloudera.com:$destinationPath"
		echo "::: Uploading $sourcePath to $target"
		scp "$sourcePath" "root@$target"
        if [ $? -ne 0 ]; then
			echo "::: Failure"
            return -1
		else
			echo "::: Success"
		fi
    done
}
