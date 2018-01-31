#!/bin/sh
# NAME
#        error.sh - Function to print an error message and exit
#
# SYNOPSIS
#        . error.sh
#        error MESSAGE [EXIT_CODE]
#
# DESCRIPTION
#        Prints messages to standard error, with color if on an interactive
#        terminal, then exits the sourcing script with the given exit code
#        (default 1).
#
# BUGS
#        https://github.com/l0b0/shell-includes/issues
#
# COPYRIGHT AND LICENSE
#        Copyright (C) 2010-2013 Victor Engmark
#
#        This program is free software: you can redistribute it and/or modify it
#        under the terms of the GNU General Public License as published by the
#        Free Software Foundation, either version 3 of the License, or (at your
#        option) any later version.
#
#        This program is distributed in the hope that it will be useful, but
#        WITHOUT ANY WARRANTY; without even the implied warranty of
#        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#        General Public License for more details.
#
#        You should have received a copy of the GNU General Public License along
#        with this program.  If not, see <http://www.gnu.org/licenses/>.
#
################################################################################

error() {
    printf '%s' "`basename -- "$0"`: " >&2

    if [ -t 1 ]
    then
        tput setf 4 || tput setaf 1
    fi

    # If the last parameter is a number, it's not part of the messages
    exit_code=1
    while true
    do
        if [ $# -eq 0 ]
        then
            break
        fi
        if [ $# -eq 1 ]
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

    if [ -t 1 ]
    then
       tput sgr0 # Reset formatting
    fi

    exit "$exit_code"
}
