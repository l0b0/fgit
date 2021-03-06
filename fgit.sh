#!/usr/bin/env bash
#
# NAME
#    fgit - Run a Git command in several repositories
#
# SYNOPSIS
#    fgit <command> [<options>] -- <path>...
#
# DESCRIPTION
#    Run a Git command, optionally with parameters, in those of the
#    specified paths which are Git repository top-level directories.
#
#    Specifying `GLOB/.git/..` paths is an easy way to process only directories
#    which contain a ".git" directory.
#
#    -h, --help
#           Output this documentation rather than Git's help.
#
# EXAMPLES
#    fgit pull -- ~/*/.git/.. ~/dev/*/.git/..
#        Run `git pull` in all the repositories in ~ and ~/dev.
#
#    fgit gc --aggressive -- */.git/..
#        Run `git gc --aggressive` in all the repositories under the current
#        directory.
#
# BUGS
#    https://github.com/l0b0/fgit/issues
#
# COPYRIGHT AND LICENSE
#    Copyright (C) 2010-2018 Victor Engmark
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

set -o errexit -o noclobber -o nounset -o pipefail

error() {
    printf '%s' "$(basename -- "$0"): " >&2

    if [[ -t 1 ]]
    then
        tput setf 4 || tput setaf 1
    fi

    # If the last parameter is a number, it's not part of the messages
    exit_code=1
    while true
    do
        if [[ $# -eq 0 ]]
        then
            break
        fi
        if [[ $# -eq 1 ]]
        then
            case "$1" in
                ''|*[!0-9]*)
                    ;;
                *)
                    exit_code="$1"
                    shift
                    continue
            esac
        fi
        printf '%s\n' "$1" >&2
        shift
    done

    if [[ -t 1 ]]
    then
       tput sgr0 # Reset formatting
    fi

    exit "$exit_code"
}

usage() {
    while IFS= read -r line || [[ -n "$line" ]]
    do
        case "$line" in
            '#!'*) # Shebang line
                ;;
            ''|'##'*|[!#]*) # End of comments
                exit "${1:-0}"
                ;;
            *) # Comment line
                printf '%s\n' "$line" >&2 # Remove comment prefix
                ;;
        esac
    done < "$0"
}

warning() {
    if [[ -t 1 ]]
    then
        tput setf 4 || tput setaf 1
    fi

    printf '%s\n' "$@" >&2

    if [[ -t 1 ]]
    then
       tput sgr0 # Reset formatting
    fi
}

# Process parameters
declare -a parameters
while [[ -n "${1:-}" ]]
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
            parameters+=( "$1" )
            shift
            ;;
    esac
done

if [[ -z "${parameters:-}" ]] || [[ $# -eq 0 ]]
then
    # Without a command or directories it's a no-operation
    usage 64
fi

for directory
do
    if [[ ! -d "${directory}/.git" ]]
    then
        warning "Not a Git repository top directory: $directory"
        continue
    fi

    git_command=(git "--work-tree=${directory}" "--git-dir=${directory}/.git" "${parameters[@]}")

    # Print the command
    printf "%q " "${git_command[@]}"
    printf '\n'

    set +o errexit
    "${git_command[@]}" || exit_code=$?
    set -o errexit
done

exit "${exit_code-0}"
