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

declare -r directory=$(dirname $(readlink -f "$0"))
declare -r cmd="${directory}/$(basename "$directory").sh"
declare -r test_name=$'--$`!*@\a\b\E\f\r\t\v\\\'\"\360\240\202\211 \n'

declare -a repos_dirs

oneTimeSetUp() {
    test_dir="${__shunit_tmpDir}/${test_name}"

    stdout_file="${test_dir}/stdout"
    stderr_file="${test_dir}/stderr"
    repos_parent="${test_dir}/repos"

    for repos_name in foo bar "$test_name"
    do
        repos_dirs+=( "${repos_parent}/${repos_name}" )
    done
}

setUp() {
    mkdir -- "$test_dir" || exit 1

    for repos_dir in "${repos_dirs[@]}"
    do
        git init -- "$repos_dir" >/dev/null || exit 1
    done
}

tearDown() {
    rm -r -- "$test_dir"
}

test_status() {
    "$cmd" status -- "$repos_parent"/* > "$stdout_file" 2> "$stderr_file"
    assertEquals 'Wrong exit code' 0 $?
    assertTrue 'Expected output to stdout' "[ -s \"\$stdout_file\" ]"
    assertFalse 'Unexpected output to stderr' "[ -s \"\$stderr_file\" ]"
}

test_parameter() {
    "$cmd" status --short  -- "$repos_parent"/* \
        > "$stdout_file" 2> "$stderr_file"
    assertEquals 'Wrong exit code' 0 $?
    assertTrue 'Expected output to stdout' "[ -s \"\$stdout_file\" ]"
    assertFalse 'Unexpected output to stderr' "[ -s \"\$stderr_file\" ]"
}

test_file_found() {
    filename='foobar'
    touch -- "${repos_dirs[0]}/${filename}"
    "$cmd" status --short  -- "$repos_parent"/* \
        > "$stdout_file" 2> "$stderr_file"
    assertEquals 'Wrong exit code' 0 $?
    assertTrue 'Expected output to stdout' "[ -s \"\$stdout_file\" ]"
    assertFalse 'Unexpected output to stderr' "[ -s \"\$stderr_file\" ]"

    assertEquals "Should find $filename" "$filename" \
        "$(grep -oe "$filename" -- "$stdout_file")"
}

# load and run shunit-ng
test -n "${ZSH_VERSION:-}" && SHUNIT_PARENT=$0
shunit2="${shunit2-shunit2}"
. "$shunit2"
