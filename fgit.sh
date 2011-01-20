#!/bin/bash
#
# NAME
#    fgit.sh - Run a Git command in several repositories
#
# SYNOPSIS
#    fgit.sh <Git command> [-- directories]
#
# DESCRIPTION
#    The script looks for repositories one level below the supplied
#    directories, if any. If no directory is supplied, the current directory
#    is used. Non-existing directories are ignored.
#
#    To be able to run this as simply `fgit`, you can either create a
#    symbolic link to it (`sudo ln -s /path/to/fgit.sh /usr/bin/fgit`) or an
#    alias in .bashrc or .bash_aliases (`alias fgit='/path/to/fgit.sh'`).
#
# EXAMPLES
#    fgit.sh pull -- ~ ~/dev
#        Run `git pull` in all the repositories under ~ and ~/dev.
#
#    fgit.sh gc --aggressive
#        Run `git gc --aggressive` in all the repositories under the current
#        directory.
#
#    fgit.sh status -s -- ~/dev
#        Run `git status -s` in all the repositories under ~/dev.
#
# BUGS
#    https://github.com/l0b0/fgit/issues
#
# COPYRIGHT AND LICENSE
#    Copyright (C) 2010-2011 Victor Engmark
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

set -o errexit
set -o nounset

# Exit codes from /usr/include/sysexits.h, as recommended by
# http://www.faqs.org/docs/abs/HTML/exitcodes.html
EX_USAGE=64

# Custom errors
EX_UNKNOWN=1

declare -r help='See documentation for more information.'

warning()
{
    # Output warning messages
    # Color the output red if it's an interactive terminal
    # @param $1...: Messages

    test -t 1 && tput setf 4

    while [ -n "${1:-}" ]
    do
        echo -E "$1" >&2
        shift
    done

    test -t 1 && tput sgr0 # Reset terminal
}

error()
{
    # Output error messages with optional exit code
    # @param $1...: Messages
    # @param $N: Exit code (optional)

    local -a messages=( "$@" )

    # If the last parameter is a number, it's not part of the messages
    local -r last_parameter="${@: -1}"
    if [[ "$last_parameter" =~ ^[0-9]*$ ]]
    then
        local -r exit_code=$last_parameter
        unset messages[$((${#messages[@]} - 1))]
    fi

    warning "${messages[@]}"

    exit ${exit_code:-$EX_UNKNOWN}
}

usage()
{
    # Print documentation until the first empty line
    local line
    while read line
    do
        if [ ! "$line" ]
        then
            exit
        elif [ "${line:0:2}" == '#!' ]
        then
            # Shebang line
            continue
        fi
        echo -E "${line:2}" # Remove comment characters
    done < "$0"
}

if [ "$#" -eq 0 ]
then
    error 'No input' "$help" $EX_USAGE
fi

# Process parameters
declare -a dirs
while [ -n "${1:-}" ]
do
    case $1 in
        --)
            shift
            dirs=("${@}")
            break
            ;;
        *)
            cmd="${cmd:-}$1 "
            shift
            ;;
    esac
done
cmd=${cmd% } # Remove last space

if [ -z "$cmd" ]
then
    error 'No command given.' "$help" $EX_USAGE
fi

if [ "$#" -ne 0 ]
then
    dirs=("${@}")
else
    # Default to current directory
    dirs[0]=.
fi

for directory in "${dirs[@]}"
do
    directory_path="$(readlink -fn -- "$directory"; echo x)"
    directory_path="${directory_path%x}"

    if [ ! -d "$directory_path" ]
    then
        continue
    fi

    while IFS= read -rd $'\0' git_dir
    do
        # Handle really weird directory names
        git_dir_path="$(dirname -- "$(readlink -fn -- "$git_dir"; echo x)")"
        git_dir_path="${git_dir_path%x}"

        cd -- "$git_dir_path"
        echo "${PWD}\$ git ${cmd}"
        git $cmd
    done < <( find "${directory_path%\/}" -mindepth 2 -maxdepth 2 -name .git -print0 )
done
