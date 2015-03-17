#!/bin/bash

# diffGitJIRAs <PROJECT> [branch] [base-branch]
# This checks for PROJECT-XXXX JIRAs that are in the 'base-branch' but not in the 'branch' branch.  It relies on the git commit
# messages following a certain format so it's not perfect.
# Arguments:
#       PROJECT - the name of the JIRA project (e.g. OOZIE, YARN, etc)
#       branch - the branch to check (defaults to the current branch)
#       base-branch - the branch to compare against (defaults to 'master')
# To include multiple projects (or different spellings/typos), you can specify an OR; for example, diffGitJIRAs "OOZIE\|OZIE\|OZZIE"
diffGitJIRAs() {
    theProject=$1
    if [ "$theProject" == "" ]; then
        echo "Must specify the PROJECT"
        return -1
    fi
    theBranch=$2
    if [ "$theBranch" == "" ]; then
        # assume current branch
        theBranch=`git branch | grep \* | cut -f2 -d" "`
    fi
    theBase=$3
    if [ "$theBase" == "" ]; then
        # assume master
        theBase=`echo master`
    fi
    # make sure branches exist
    git branch | grep $theBranch &> /dev/null
    if [ $? -ne 0 ]; then
        echo "The \"$theBranch\" branch does not exist"
        return -1
    fi
    git branch | grep $theBase &> /dev/null
    if [ $? -ne 0 ]; then
        echo "The \"$theBase\" branch does not exist"
        return -1
    fi

    echo "# \"$theProject\" JIRAs that are in the \"$theBase\" branch but not in the \"$theBranch\" branch:"
    export r=`mktemp -d /tmp/diff-XXXXX`
    export baseFile=$r/baseFile
    # This gets the PROJECT-XXXX values from the lines that start with it
    git log $theBase --oneline | cut -f2 -d" " | grep "$theProject" | cut -f1 -d':' | cut -f1 -d'.' > $baseFile
    # This gets PROJECT-XXXX values from lines like this: "Merge r1607833 from Trunk: YARN-2251. Avoid negative..."
    git log $theBase --oneline | cut -f10 -d" " |  grep "$theProject" | cut -f1 -d':' | cut -f1 -d'.' >> $baseFile
    export sortedBaseFile=$r/sortedBaseFile
    cat $baseFile | sort | uniq > $sortedBaseFile
    export branchFile=$r/branchFile
    git log $theBranch --oneline | cut -f2 -d" " | grep "$theProject" | cut -f1 -d':' | cut -f1 -d'.' > $branchFile
    git log $theBranch --oneline | cut -f10 -d" " |  grep "$theProject" | cut -f1 -d':' | cut -f1 -d'.' >> $branchFile
    export sortedBranchFile=$r/sortedBranchFile
    cat $branchFile | sort | uniq > $sortedBranchFile
    export diffFile=$r/diffFile
    comm -2 -3 $sortedBaseFile $sortedBranchFile > $diffFile
    grep -Ff $diffFile $baseFile
}

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
