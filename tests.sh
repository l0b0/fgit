#!/bin/bash
#
#

oneTimeSetUp()
{
    declare -r directory="$(dirname -- "$(readlink -f -- "$0")")"

    # Weird filename
    declare -r test_filename=$'--$`\! *@ \a\b\e\E\f\r\t\v\\\"\' \n'

    test_dir="${__shunit_tmpDir}/${test_filename}"
    mkdir -- "${test_dir}" || exit 1
    stdout_file="${test_dir}/stdout"
    stderr_file="${test_dir}/stderr"

    # Command to test
    cmd="${directory}/fgit.sh"
    test -x "$cmd" || exit 1
    
    # Repositories
    repos_parent="${test_dir}/repos"
    repos_dirs='foo bar'
    for repos_dir in $repos_dirs
    do
        git init -- "${repos_parent}/${repos_dir}" || exit 1
    done
}


tearDown()
{
    rm -f -- "${test_dir}/stdout" "${test_dir}/stderr"
}


test_status()
{
    "${cmd}" status -- "${repos_parent}" > >(tee "${stdout_file}") 2> >(tee "${stderr_file}" >&2)
    exit_code=$?
    assertEquals 'Wrong exit code' 0 $exit_code
    assertNotNull 'Expected output to stdout' "$(cat "${stdout_file}")"
    assertNull 'Unexpected output to stderr' "$(cat "${stderr_file}")"
}

# load and run shunit-ng
test -n "${ZSH_VERSION:-}" && SHUNIT_PARENT=$0
. shunitng
