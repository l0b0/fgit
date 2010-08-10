#!/bin/bash
#
# NAME
#    fgit.sh - Run a Git command in several repositories
#
# SYNOPSIS
#    fgit.sh <Git command> [-- directories]
#
# EXAMPLES
#    fgit.sh pull
#        Run `git pull` in all the repositories under the current directory.
#
#    fgit.sh status -s -- ~/dev /foo
#        Run `git status -s` in all the repositories under ~/dev and /foo.
#
# DESCRIPTION
#    The script looks for repositories one level below the supplied
#    directories, if any. If no directory is supplied, the current directory
#    is used. Non-existing directories are ignored.
#
#    To be able to run this as simply `fgit`, you can either create a
#    symbolic link to it (`ln -s /path/to/fgit.sh /usr/bin/fgit`) or an
#    alias in .bashrc or .bash_aliases (`alias fgit='/path/to/fgit.sh'`).
#
# BUGS
#    Email bugs to victor dot engmark at gmail dot com.
#
# COPYRIGHT AND LICENSE
#    Copyright (C) 2010 Victor Engmark
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
################################################################################

ifs_original="$IFS"
PATH='/usr/bin:/bin'
cmdname=$(basename $0)
directory=$(dirname $0)

# Exit codes from /usr/include/sysexits.h, as recommended by
# http://www.faqs.org/docs/abs/HTML/exitcodes.html
EX_USAGE=64

# Custom errors
EX_UNKNOWN=1

# Output error message with optional error code
error()
{
    # Return to origin
    cd $directory

    # Output error message (in color if supported)
    test -t 1 \
    && {
        tput setf 4
        echo "$1" >&2
        tput setf 7
    } \
    || echo "$1" >&2

    # Exit
    if [ -z "$2" ]
    then
        exit $EX_UNKNOWN
    else
        exit $2
    fi
}

usage()
{
    # Return to origin
    cd $directory

    # Print documentation until the first empty line
    while read line
    do
        if [ ! "$line" ]
        then
            exit $EX_USAGE
        fi
        echo "$line"
    done < $0
}

# Process parameters
IFS=' '
cmd=''
while [ -n "$1" ]
do
    case $1 in
        --)
            shift
            break
            ;;
        *)
            cmd="${cmd}$1 "
            shift
            ;;
    esac
done
cmd=${cmd% }
IFS=$(echo -en "\n\b")

dirs=$*

# Default to current subdirectories
if [ -z "$dirs" ]
then
    dirs=.
fi

for dir in $dirs
do
    if [ ! -d "$dir" ]
    then
        continue
    fi

    find ${dir%\/}/* -maxdepth 1 -name .git -print0 | while read -d $'\0' git_dir
    do
        dir=$(dirname $git_dir)
        cd $dir
        IFS="$ifs_original"
        echo "${PWD}\$ git ${cmd}"
        git $cmd
        cd - >/dev/null
    done
done
IFS="$ifs_original"
