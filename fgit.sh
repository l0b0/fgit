#!/bin/bash
#
# NAME
#    fgit.sh - Run a Git command in several repositories
#
# SYNOPSIS
#    fgit.sh COMMAND -- PATH ...
#
# DESCRIPTION
#    Run a Git command, optionally with parameters, in those of the
#    specified PATHs which are Git repository top-level directories.
#
#    -h, --help
#           Output this documentation.
#
# EXAMPLES
#    fgit.sh pull -- ~/* ~/dev/*
#        Run `git pull` in all the repositories in ~ and ~/dev.
#
#    fgit.sh gc --aggressive
#        Run `git gc --aggressive` in all the repositories under the current
#        directory.
#
#    fgit.sh status -s -- ~/dev/*
#        Run `git status -s` in all the repositories in ~/dev.
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

declare -r help_info="Try \`$(basename -- "$0") --help\` for more information."

warning()
{
    # Output warning messages
    # Color the output red if it's an interactive terminal
    # @param $1...: Messages

    test -t 1 && tput setf 4

    printf '%s\n' "$@" >&2

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
    # @param $1: Exit code (optional)
    local line
    while IFS= read line
    do
        if [ -z "$line" ]
        then
            exit ${1:-0}
        elif [ "${line:0:2}" == '#!' ]
        then
            # Shebang line
            continue
        fi
        echo "${line:2}" # Remove comment characters
    done < "$0"
}

if [ "$#" -eq 0 ]
then
    usage $EX_USAGE
fi

# Process parameters
declare -a cmd
while [ -n "${1:-}" ]
do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            cmd+=( "$1" )
            shift
            ;;
    esac
done

if [ -z "${cmd:-}" -o $# -eq 0 ]
then
    # Without a command or directories it's a no-operation
    usage $EX_USAGE
fi

for directory
do
    if [ ! -d "${directory}/.git" ]
    then
        warning "Not a Git repository top directory: $directory"
        continue
    fi

    cd -- "$directory"

    # Print the command
    printf %s "${PWD}\$ git "
    printf "%q " "${cmd[@]}"
    printf '\n'

    set +o errexit
    git "${cmd[@]}"
    set -o errexit

    cd - >/dev/null
done
