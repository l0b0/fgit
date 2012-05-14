#!/usr/bin/env bash
#
# NAME
#    test.sh - Test fgit.sh script
#
# BUGS
#    https://github.com/l0b0/fgit/issues
#
# COPYRIGHT AND LICENSE
#    Copyright (C) 2011-2012 Victor Engmark
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

#set -o errexit # Enable when shunit works with it
set -o nounset

declare -r directory="$(dirname -- "$(readlink -f -- "$0")")"

# Command to test
declare -r cmd="${directory}/fgit.sh"

# Weird filename
declare -r test_filename=$'--$`\! *@ \a\b\e\E\f\r\t\v\\\"\' \n'

declare -a repos_dirs

oneTimeSetUp()
{
    test -x "$cmd" || exit 1

    # Test directories and files
    test_dir="${__shunit_tmpDir}/${test_filename}"
    mkdir -- "$test_dir" || exit 1

    stdout_file="${test_dir}/stdout"
    stderr_file="${test_dir}/stderr"

    repos_parent="${test_dir}/repos"
    repos_names=( foo bar "$test_filename" )
    for repos_name in "${repos_names[@]}"
    do
        repos_dir="${repos_parent}/${repos_name}"
        repos_dirs+=( "$repos_dir" )
        git init -- "${repos_dir}" || exit 1
    done
}

test_status()
{
    "$cmd" status -- "$repos_parent"/* > "$stdout_file" 2> "$stderr_file"
    exit_code=$?
    assertEquals 'Wrong exit code' 0 $exit_code
    assertNotNull 'Expected output to stdout' "$(cat "$stdout_file")"
    assertNull 'Unexpected output to stderr' "$(cat "$stderr_file")"
}

test_parameter()
{
    "$cmd" status --short  -- "$repos_parent"/* \
        > "$stdout_file" 2> "$stderr_file"
    exit_code=$?
    assertEquals 'Wrong exit code' 0 $exit_code
    assertNotNull 'Expected output to stdout' "$(cat "$stdout_file")"
    assertNull 'Unexpected output to stderr' "$(cat "$stderr_file")"
}

test_file_found()
{
    filename='foobar'
    touch -- "${repos_dirs[0]}/${filename}"
    "$cmd" status --short  -- "$repos_parent"/* \
        > "$stdout_file" 2> "$stderr_file"
    exit_code=$?
    assertEquals 'Wrong exit code' 0 $exit_code
    assertNotNull 'Expected output to stdout' "$(cat "$stdout_file")"
    assertNull 'Unexpected output to stderr' "$(cat "$stderr_file")"

    assertEquals "Should find $filename" "$filename" \
        "$(grep -oe "$filename" -- "$stdout_file")"
}

# load and run shunit-ng
test -n "${ZSH_VERSION:-}" && SHUNIT_PARENT=$0
. shunitng
