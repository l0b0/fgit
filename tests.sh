#!/bin/bash
#
#

oneTimeSetUp()
{
    declare -r directory="$(dirname -- "$(readlink -f -- "$0")")"

    # Weird filename fragment to test quoting / escaping
    # Remember that only forward slash (/) and the null character cannot be part
    # of a filename
    # "A -- signals the end of options and disables further option processing."
    # man bash
    declare -r test_filename=$'--$`\! *@ \a\b\e\E\f\r\t\v\\\"\' \n'

    outputDir="${__shunit_tmpDir}/output"
    mkdir "${outputDir}"
    stdout_file="${outputDir}/stdout"
    stderr_file="${outputDir}/stderr"
    
    cmd="${directory}/fgit.sh"
}


tearDown()
{
    rm -f -- "${outputDir}/stdout" "${outputDir}/stderr"
}


test_help()
{
    "${cmd}" -h > >(tee "${stdout_file}") 2> >(tee "${stderr_file}" >&2)
    exit_code=$?
    assertEquals 'Wrong exit code' 0 $exit_code
    assertNotNull 'Expected output to stdout' "$(cat "${stdout_file}")"
    assertNull 'Unexpected output to stderr' "$(cat "${stderr_file}")"

    "${cmd}" --help -- "$source" > >(tee "${stdout_file}") 2> >(tee "${stderr_file}" >&2)
    exit_code=$?
    assertEquals 'Wrong exit code' 0 $exit_code
    assertNotNull 'Expected output to stdout' "$(cat "${stdout_file}")"
    assertNull 'Unexpected output to stderr' "$(cat "${stderr_file}")"

    assertEquals 'Missing files' $test_days "$(file_count "$source")"
}


# Create repository


# Add contents


# Test status


# Test


# load and run shunit-ng
test -n "${ZSH_VERSION:-}" && SHUNIT_PARENT=$0
. shunitng
