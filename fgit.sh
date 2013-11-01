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
#    -h, --help
#           Output this documentation rather than Git's help.
#
# EXAMPLES
#    fgit pull -- ~/*/ ~/dev/*/
#        Run `git pull` in all the repositories in ~ and ~/dev.
#
#    fgit gc --aggressive -- */
#        Run `git gc --aggressive` in all the repositories under the current
#        directory.
#
#    fgit status -s -- ~/dev/*/
#        Run `git status -s` in all the repositories in ~/dev.
#
# BUGS
#    https://github.com/l0b0/fgit/issues
#
# COPYRIGHT AND LICENSE
#    Copyright (C) 2010-2013 Victor Engmark
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

includes="$(dirname -- "$0")"/shell-includes
. "$includes"/error.sh
. "$includes"/usage.sh
. "$includes"/variables.sh
. "$includes"/warning.sh
unset includes

# Process parameters
declare -a parameters
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
            parameters+=( "$1" )
            shift
            ;;
    esac
done

if [ -z "${parameters:-}" -o $# -eq 0 ]
then
    # Without a command or directories it's a no-operation
    usage $ex_usage
fi

for directory
do
    if [ ! -d "${directory}/.git" ]
    then
        warning "Not a Git repository top directory: $directory"
        continue
    fi

    git_command=(git --work-tree="$directory" --git-dir="${directory}/.git" "${parameters[@]}")

    # Print the command
    printf "%q " "${git_command[@]}"
    printf '\n'

    set +o errexit
    "${git_command[@]}" || exit_code=$?
    set -o errexit
done

exit ${exit_code-0}
