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

# To build Hadoop (mr2)
alias mvnHadoop='mvn clean package -Pdist -Dtar -Dmaven.javadoc.skip=true -DskipTests'
# To build Hadoop (mr1)
alias antHadoop='ant jar -Dreactor.repo=file:///dev/null'


alias gcp='git cherry-pick -x'

# I make this typo a lot
alias opne='open'


# Generates a list of PROJECT-XXXX (or PROJECT_XXXX) JIRA numbers that are in the $2 branch but not in the $1 branch
# If the second argument is not given, the default is to compare the $1 branch with the “master” branch
# If neither arguments are given, the default is to compare the current branch with the “master” branch
# (Oozie uses “master” instead of trunk in git now)
diffGitJIRAs() {
	theBranch=$1
	if [ "$theBranch" == "" ]; then
		theBranch=`git branch | grep \* | cut -f2 -d" "`
	fi
	theBase=$2
	if [ "$theBase" == "" ]; then
		theBase=`echo master`	# for some reason, theBase=“master” was including the quotes
	fi
	echo "# JIRAs numbers that are in the \"$theBase\" branch but not in the \"$theBranch\" branch:"
	export r=`mktemp -d /tmp/diff-XXXXX`
	export baseFile=$r/baseFile
	# this gets the JIRA number from lines like "OOZIE-1177 HostnameFilter should…"
	git log $theBase --oneline | cut -f2 -d" " | cut -f2 -d- | cut -f2 -d_ > $baseFile
	# this gets the JIRA number from lines like "Merge -r 1341945:1341946 from trunk to branch. FIXES: OOZIE-851"
	git log $theBase --oneline | cut -f10 -d" " |  grep OOZIE | cut -f2 -d- | cut -f2 -d_ >> $baseFile
	export sortedBaseFile=$r/sortedBaseFile
	cat $baseFile | sort | uniq > $sortedBaseFile
	export branchFile=$r/branchFile
	git log $theBranch --oneline | cut -f2 -d" " | cut -f2 -d- | cut -f2 -d_ > $branchFile
	git log $theBranch --oneline | cut -f10 -d" " |  grep OOZIE | cut -f2 -d- | cut -f2 -d_ >> $branchFile
	export sortedBranchFile=$r/sortedBranchFile
	cat $branchFile | sort | uniq > $sortedBranchFile
	export diffFile=$r/diffFile
	comm -2 -3 $sortedBaseFile $sortedBranchFile > $diffFile
	grep -Ff $diffFile $baseFile
}

# Resets and checks out the original version of a file under git
# Useful when cherry picking and have to ignore the "conflict" in a CHANGES.txt or release-log.txt file etc
greset() {
	if [ "$1" == "" ]; then
		echo "error: missing filename"
		return -1
	fi
	if [ "$1" == "." ]; then
		echo "error: filename cannot be '.'"
		return -1
	fi
	if [[ "$1" != /* ]] || [[ "$1" == $PWD* ]]; then
		git reset $1
		git checkout -- $1
	else
		echo "error: filename must be in current directory ($PWD)"
		return -1
	fi
}

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

# Print out a maven formatted list of modified or new Test*.java files from a git commit
# Useful for easily getting a list of tests to run from mvn from a backport cherry-pick
gTests() {
	# get modified Tests
	export modifiedTests=`git status | grep '\W*modified' | cut -f 4 -d ' ' | grep '/Test.*\.java$' | awk -F/ '{print $(NF)}' | cut -f 1 -d '.' | tr -s '\n' ','`
	# get new Tests
	export newTests=`git status | grep '\W*new file' | cut -f 5 -d ' ' | grep '/Test.*\.java$' | awk -F/ '{print $(NF)}' | cut -f 1 -d '.' | tr -s '\n' ','`
	# echo both lists as one list and remove the trailing comma
	echo $modifiedTests$newTests | awk '{ print substr($0,1,length($0)-1) }'
}

# Same as gTests() but for svn
sTests() {
	# get modified and new Tests
	export modifiedAndNewTests=`svn status | grep '^[M,A]' | cut -f 8 -d ' ' | grep '/Test.*\.java$' | awk -F/ '{print $(NF)}' | cut -f 1 -d '.' | tr -s '\n' ','`
	# echo the list and remove the trailing comma
	echo $modifiedAndNewTests | awk '{ print substr($0,1,length($0)-1) }'
}

# svn add all files marked as ?
svnAddAll() {
	for newFile in `svn status | grep '^?' | awk '{print $2}'`
	do
		svn add $newFile
	done
}

# svn delete all files marked as !
svnDelAll() {
	for newFile in `svn status | grep '^!' | awk '{print $2}'`
	do
		svn rm $newFile
	done
}

# svn revert all (to clean state)
svnRevertAll() {
	svn revert -R .
	for newFile in `svn status | grep '^?' | awk '{print $2}'`
	do
		rm -r $newFile
	done
}


# given a list of git hashes, sort them by commit order
gitOrder() {
	theFile=`mktemp /tmp/gitOrder-XXXXXXXXXXXX`
	# For each hash, dump it into a file with its timestamp in unix format
	for hash in $@
	do
		git log --pretty=format:"%ct %H" $hash^..$hash >> $theFile
		echo "" >> $theFile
	done
	# sort the file (timestamp is first so it will be sorted by timestamp) and print the hashes back
	sort $theFile | cut -d' ' -f 2
}

