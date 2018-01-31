#!/bin/sh
# NAME
#        variables.sh - Commonly used variables
#
# SYNOPSIS
#        . variables.sh
#
# DESCRIPTION
#        See the individual variables.
#
# BUGS
#        https://github.com/l0b0/shell-includes/issues
#
# COPYRIGHT AND LICENSE
#        Copyright (C) 2010-2012 Victor Engmark
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

# Exit codes from /usr/include/sysexits.h, as recommended by
# http://www.faqs.org/docs/abs/HTML/exitcodes.html
ex_ok=0           # Successful termination
ex_usage=64       # Command line usage error
ex_dataerr=65     # Data format error
ex_noinput=66     # Cannot open input
ex_nouser=67      # Addressee unknown
ex_nohost=68      # Host name unknown
ex_unavailable=69 # Service unavailable
ex_software=70    # Internal software error
ex_oserr=71       # System error (e.g., can't fork)
ex_osfile=72      # Critical OS file missing
ex_cantcreat=73   # Can't create (user) output file
ex_ioerr=74       # Input/output error
ex_tempfail=75    # Temp failure; user is invited to retry
ex_protocol=76    # Remote error in protocol
ex_noperm=77      # Permission denied
ex_config=78      # Configuration error

# All other errors
ex_unknown=1

# Base name of the sourcing script
script="`basename -- "$0"`"
