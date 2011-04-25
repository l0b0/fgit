#!/bin/bash
#
# Test fgit.sh

#set -o errexit # Enable when shunit works with it
set -o nounset

declare -r directory="$(dirname -- "$(readlink -f -- "$0")")"

# Command to test
declare -r cmd="${directory}/fgit.sh"

# Weird filename
declare -r test_filename=$'--$`\! *@ \a\b\e\E\f\r\t\v\\\"\' \n'

# Repositories
declare -a repos_dirs=( foo bar )


oneTimeSetUp()
{
    test -x "$cmd" || exit 1

    # Test directories and files
    test_dir="${__shunit_tmpDir}/${test_filename}"
    mkdir -- "$test_dir" || exit 1

    stdout_file="${test_dir}/stdout"
    stderr_file="${test_dir}/stderr"

    repos_parent="${test_dir}/repos"

    for repos_dir in "${repos_dirs[@]}"
    do
        git init -- "${repos_parent}/${repos_dir}" || exit 1
    done
}


test_status()
{
    "$cmd" status -- "$repos_parent" \
        > "$stdout_file" 2> "$stderr_file"
    exit_code=$?
    assertEquals 'Wrong exit code' 0 $exit_code
    assertNotNull 'Expected output to stdout' "$(cat "$stdout_file")"
    assertNull 'Unexpected output to stderr' "$(cat "$stderr_file")"
}


test_parameter()
{
    "$cmd" status --short  -- "$repos_parent" \
        > "$stdout_file" 2> "$stderr_file"
    exit_code=$?
    assertEquals 'Wrong exit code' 0 $exit_code
    assertNotNull 'Expected output to stdout' "$(cat "$stdout_file")"
    assertNull 'Unexpected output to stderr' "$(cat "$stderr_file")"
}


test_file_found()
{
    filename='foobar'
    touch -- "${repos_parent}/${repos_dirs[0]}/${filename}"
    "$cmd" status --short  -- "$repos_parent" \
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
