#!/bin/bash

# This script defines a number of general purpose functions.
# For the functions to be invocable by other scripts, this script needs to be sourced.
# When fatal parameter errors are detected, the script invokes exit, which leads to exiting the current shell.

#-------------------------------------------------------------------------------
# Common scripts variables and environment initialization
#-------------------------------------------------------------------------------


# commonly used variables
ci=${CI:-false}
initial_dir=$(pwd)
declare -ix errors=0
declare -xr ci=${CI:-false}
declare -xr initial_dir
declare -x debugger=${DEBUGGER:-false}
declare -x verbose=${VERBOSE:-false}
declare -x dry_run=${DRY_RUN:-false}
declare -x quiet=${QUIET:-false}
declare -x _ignore=/dev/null  # the file to redirect unwanted output to
declare -x github_output=${GITHUB_OUTPUT:-/dev/null}
declare -x github_step_summary=${GITHUB_STEP_SUMMARY:-/dev/stdout}

declare last_command
declare current_command="$BASH_COMMAND"

# on_debug when specified as a handler of the DEBUG trap, remembers the last invoked bash command in $last_command.
# on_debug and on_exit are trying to cooperatively do error handling when exit is invoked. To be effective, after
# sourcing this script, set these signal traps:
#   trap on_debug DEBUG
#   trap on_exit EXIT
function on_debug() {
    # keep track of the last executed command
    last_command="$current_command"
    current_command="$BASH_COMMAND"
}

# on_exit when specified as a handler of the EXIT trap
#   * if on_debug handles the DEBUG trap, displays the failed command
#   * if $initial_dir is defined, changes the current working directory to it
#   * does `set +x`.
# on_debug and on_exit are trying to cooperatively do error handling when exit is invoked. To be effective, after
# sourcing this script, set these signal traps:
#   trap on_debug DEBUG
#   trap on_exit EXIT
function on_exit() {
    # echo an error message before exiting
    local x=$?
    if ((x != 0)); then
        echo "'$last_command' command failed with exit code $x" >&2
    fi
    if [[ -n "$initial_dir" ]]; then
        cd "$initial_dir" || exit
    fi
    set +x
}

trap on_debug DEBUG
trap on_exit EXIT

## Sets the script to CI mode
function set_ci()
{
    quiet=true
    dry_run=false
    verbose=false
    debugger=false
    _ignore=/dev/null
    set +x
    return 0
}

## Sets the script to debugger mode
function set_debugger()
{
    if [[ $ci == true ]]; then
        # do not allow in CI mode
        debugger=false
    else
        debugger=true
        quiet=true
    fi
    return 0
}

## Enables trace mode for debugging
function set_trace_enabled()
{
    if [[ $ci == true ]]; then
        # do not allow in CI mode
        verbose=false
        _ignore=/dev/null
        set +x
    else
        verbose=true
        _ignore=/dev/stdout
        set -x
    fi
    return 0
}

## Sets the script to dry-run mode (does not execute commands, only simulates)
function set_dry_run()
{
    if [[ $ci == true ]]; then
        # do not allow in CI mode
        dry_run=false
    else
        dry_run=true
    fi
    return 0
}

## Sets the script to quiet mode (suppresses user prompts)
function set_quiet()
{
    if [[ $ci == true ]]; then
        # do not use user prompts in CI mode
        quiet=true
    else
        quiet=false
    fi
    return 0
}

## Sets the script to verbose mode (enables detailed output)
function set_verbose()
{
    verbose=true
    return 0
}

if [[ $ci == true ]]; then
    set_ci
fi
if [[ $debugger == true ]]; then
    set_debugger
fi
if [[ $dry_run == true ]]; then
    set_dry_run
fi
if [[ $quiet == true ]]; then
    set_quiet
fi
if [[ $verbose == true ]]; then
    set_verbose
fi

gth="┌────────────────────────────────────────────────────────────────────────────"
gbh="├──────────────────────────────────────┬─────────────────────────────────────"
gmt="├──────────────────────────────────────┴─────────────────────────────────────"
gmb="├──────────────────────────────────────┬─────────────────────────────────────"
gln="├──────────────────────────────────────┼─────────────────────────────────────"
gbl="│                                      │                                     "
gbt="└──────────────────────────────────────┴─────────────────────────────────────"
ghf="│ %s\n"
gvf="│ \$%-35s │ %-35s\n"

# shellcheck disable=SC2034
declare -A graphical=(
    ["top_header"]=$gth
    ["bottom_header"]=$gbh
    ["top_mid_header"]=$gmt
    ["bottom_mid_header"]=$gmb
    ["header_format"]=$ghf
    ["line"]=$gln
    ["value_format"]=$gvf
    ["blank"]=$gbl
    ["bottom"]=$gbt
)

mbh="|:-------------------------------------|:------------------------------------|"
mln="|--------------------------------------|-------------------------------------|"
mbl="|                                      |                                     |"
mhf="| %-36s |                                     |\n"
mvf="| \$%-35s | %-35s |\n"

# shellcheck disable=SC2034
declare -A markdown=(
    ["top_header"]=""
    ["bottom_header"]=$mbh
    ["top_mid_header"]=$mln
    ["bottom_mid_header"]=$mln
    ["header_format"]=$mhf
    ["line"]=$mln
    ["value_format"]=$mvf
    ["blank"]=$mbl
    ["bottom"]=""
)

declare table_format="graphical"

## Dumps a table of variables and in the end asks the user to press any key to continue.
## The names of the variables must be specified as strings - no leading $.
## Optionally the caller can specify flags like:
## -h or --header <text> will display the header text and the dividing lines in the table, so pass the top header text first.
##         Subsequent headers will be treated as mid headers
## -m or --markdown will display the table in markdown format instead of graphical
## -b or --blank will display an blank line in the table
## -l or --line will display a dividing line
## -q or --quiet will not ask the user to press a key to continue after dumping the variables
## -f or --force will dump the variables even if $verbose is not true
function dump_vars() {
    if (( $# == 0 )); then
        return;
    fi
    local force_verbose=false
    local save_quiet=$quiet
    for v in "$@"; do
        case $v in
             -m|--markdown) table_format="markdown" ;;
             -f|--force)    force_verbose=true ;;
             -q|--quiet )   quiet=true ;;
             * )            ;;
        esac
    done
    if [[ $verbose == false && $force_verbose == false ]]; then
        return;
    fi

    # Save the current _ignore value and disable output for tracing
    local save_ignore=$_ignore
    _ignore=/dev/null
    local set_tracing_on=0
    if [[ $- =~ .*x.* ]]; then
        set_tracing_on=1
    fi
    set +x
    if [[ $table_format == "markdown" ]]; then
        local -n table=markdown
    else
        local -n table=graphical
    fi

    local top=true

    until [[ $# = 0 ]]; do
        v=$1
        shift
        case $v in
            -h|--header )
                v=$1
                shift
                if [[ $top == true ]]; then
                    echo "${table["top_header"]}"
                    _write_title "$v"
                    echo "${table["bottom_header"]}"
                else
                    echo "${table["top_mid_header"]}"
                    _write_title "$v"
                    echo "${table["bottom_mid_header"]}"
                fi
                ;;

            -b|--blank ) echo "${table["blank"]}" ;;
            -l|--line ) echo "${table["line"]}" ;;
            * ) if [[ ! $v =~ ^-.* ]]; then _write_line "$v"; fi
                # all other options starting with '-' are already processed
                ;;
        esac
        top=false
    done
    echo "${table["bottom"]}"
    sync
    press_any_key

    quiet=$save_quiet
    _ignore=$save_ignore
    table_format="graphical"
    if ((set_tracing_on == 1)); then
        set -x
    fi
    return 0
}

## internal function to write a line for a variable in the variable dump table
function _write_title() {
    if [[ $table_format == "markdown" ]]; then
        local -n table=markdown
    else
        local -n table=graphical
    fi
    # shellcheck disable=SC2059
    printf "${table["header_format"]}" "$1"
    return 0
}

function _write_line() {
    local -n v="$1"
    local value

    if declare -p "$1" 2>/dev/null | grep -q 'declare -[xir-]'; then
        value="$v"
    elif declare -p "$1" 2>/dev/null | grep -q 'declare -a'; then
        value="${#v[@]}: (${v[*]})"
    elif declare -p "$1" 2>/dev/null | grep -q 'declare -A'; then
        first=true
        for key in "${!v[@]}"; do
            if [[ $first == true ]]; then
                value="${#v[@]}: ($key→${v[$key]}"
                first=false
            else
                value+=", $key→${v[$key]}"
            fi
        done
        value+=")"
    elif declare -pF "$1" 2>/dev/null | grep -q 'declare -f'; then
        value="$1()"
    elif ! is_defined "$1"; then
        value="****** unbound, undefined, or invalid"
    else
        value="$v"
    fi

    if [[ $table_format == "markdown" ]]; then
        local -n table=markdown
    else
        local -n table=graphical
    fi
    # shellcheck disable=SC2059
    printf "${table["value_format"]}" "$1" "$value"
    return 0
}

## Shell function to test if a variable is defined.
## Usage: is_defined <variable_name>
function is_defined() {
    if [[ $# -ne 1 ]]; then
        echo "The function is_defined() requires exactly one argument: the name of the variable to test." >&2
        return 2
    fi
    [[ -v "e" ]] || declare -p e > /dev/null
}

## Shell function to log error messages to the standard output and to the GitHub step summary (github_step_summary).
## Increments the error counter.
## Usage: error <message1> [<message2> ...]
# shellcheck disable=SC2154
function error()
{
    echo "❌  ERROR $*" | tee -a "$github_step_summary" >&2
    errors=$((errors + 1))
    return 0
}

## Shell function to log warning messages to the standard output and to the GitHub step summary (github_step_summary).
## Usage: warning <message1> [<message2> ...]
function warning()
{
    echo "⚠️  WARNING $*" | tee -a "$github_step_summary"
    return 0
}

## Shell function to log informational messages to the standard output and to the GitHub step summary (github_step_summary).
## Usage: info <message1> [<message2> ...]
function info()
{
    echo "ℹ️  INFO $*" | tee -a "$github_step_summary"
    return 0
}

## Shell function to log a warning about a variable's value and set it to a default value to the standard output and to the
## GitHub step summary (github_step_summary).
## Usage: warning_var <variable_name> <warning message> <variable's default value>
function warning_var()
{
    declare -n variable="$1";
    # shellcheck disable=SC2034
    warning "$2" "Assuming the default value of '$3'."
    variable="$3"
}

## Shell function to output a variable to GitHub Actions output (GITHUB_OUTPUT).
## Usage: to_github_output <variable_name> [<output_name>]
## Note that if no output name is specified, then it is defined as the variable name with all underscores in the variable name
## converted to hyphens for GitHub Actions output, e.g.
## `to_github_output build_projects` will output `build-projects=<value of $build_projects>` to $github_output or
## `to_github_output build_projects test-projects` will output `test-projects=build-projects` to $github_output
# shellcheck disable=SC2154
function to_github_output()
{
    if [[ $# -ge 2 || $# -le 1 ]]; then
        error "to_github_output() requires one or two arguments: the name of the variable to output and possibly the name to use in GitHub Actions output."
    fi

    declare -n variable="$1"
    local modified
    if [[ $# -eq 1 ]]; then
        modified="${1//_/-}"
    else
        modified="$2"
    fi

    echo "${modified}=${variable}" >> "${github_output}"
}

function args_to_github_output()
{
    if [[ $# -le 1 ]]; then
        error "list_to_github_output() requires one or more argument: the names of the variables to output."
        return 2
    fi

    {
        local m
        for v in "$@"; do
            declare -n var="$v"
            m="${var//_/-}"
            echo "${m}=${var}"
        done
    } >> "$github_output"
}

## Processes common command-line arguments like --debugger, --quiet, --verbose, --trace, --dry-run.
## Usage: get_common_arg <argument>
function get_common_arg()
{
    if [[ "${#}" -eq 0 ]]; then
        return 2
    fi
    # the calling scripts should not use short options -q -v -x -y
    case "${1,,}" in
        --debugger   ) set_debugger ;;
        --quiet|-q   ) set_quiet ;;
        --verbose|-v ) set_verbose ;;
        --trace|-x   ) set_trace_enabled ;;
        --dry-run|-y ) set_dry_run ;;
        *            ) return 1 ;;  # not a common argument
    esac
    return 0 # it was a common argument and was processed
}

declare -x common_switches="
    --debugger
        Set when the script is running under a debugger, e.g. 'gdb'. If
        specified, the script will not set traps for DEBUG and EXIT, and will
        set the '--quiet' switch.
        Initial value from \$DEBUGGER or 'false'

    --dry-run | -y
        Runs the script without executing any commands but shows what would have
        been executed.
        Initial value from \$DRY_RUN or 'false'

    --help | -h | -?
        Displays this usage text and exits.

    --quiet | -q
        Suppresses all prompts for input from the user, and assumes the default
        answers.
        Initial value from \$QUIET or 'false'

    --trace | -x
        Sets the Bash trace option 'set -x' and enables the output from the
        functions 'trace' and 'dump_vars'.
        Initial value from \$TRACE_ENABLED or 'false'

    --verbose | -v
        Enables verbose output: all output from the invoked commands (e.g. jq,
        dotnet, etc.) to be sent to 'stdout' instead of '/dev/null'. It also
        enables the output from the script function trace() and all other
        commands and functions that are otherwise silent.
        Initial value from \$VERBOSE or 'false'
"

## Displays a usage message and optionally an additional message.
## Usage: display_usage_msg <usage_text> [<additional_message>]
function display_usage_msg()
{
    if [[ "${#}" -eq 0 || -z "$1" ]]; then
        echo "There must be at least one parameter - the usage text" >&2
        exit 2
    fi

    # save the tracing state and disable tracing
    local set_tracing_on=0
    if [[ $- =~ .*x.* ]]; then
        set_tracing_on=1
    fi
    set +x

    echo "$1
"
    if [[ "${#}" -gt 1 && -n "$2" ]]; then
        echo "$2
"
    fi
    sync

    # restore the tracing state
    if ((set_tracing_on == 1)); then
        set -x
    fi
    return 0
}

## Logs a trace message if verbose mode is enabled.
## Usage: trace <message>
function trace() {
    if [[ "$verbose" == true ]]; then
        echo "Trace: $*" >&2
    fi
    return 0
}

## Depending on the value of $dry_run either executes or just displays what would have been executed.
## Usage: execute <command> [args...]
function execute() {
    if [[ "$dry_run" == true ]]; then
        echo "dry-run$ $*"
        return 0
    fi
    trace "$*"
    "$@"
    return $?
}

# to_lower converts all characters in the passed in value to lowercase and prints the to stdout.
# Usage example: local a="$(to_lower "$1")"
function to_lower() {
    printf "%s" "${1,,}"
    return 0
}

# to_upper converts all characters in the passed in value to uppercase and prints the to stdout.
# Usage example: local a="$(to_upper "$1")"
function to_upper() {
    printf "%s" "${1^^}"
    return 0
}

# capitalize converts the first character in the passed in value to upper case and the rest to lowercase and prints the to stdout.
# Usage example: local a="$(capitalize "$1")"
function capitalize() {
    a="${1,,}"
    printf "%s" "${a^}"
    return 0
}

## Tests if the parameter represents a valid positive, integer number (aka natural number): {1, 2, 3, ...}
## Usage: is_positive <number>
function is_positive() {
    [[ "$1" =~ ^[+]?[0-9]+$  && ! "$1" =~ ^[+]?0+$ ]]
}

## Tests if the parameter represents a valid non-negative integer number: {0, +0, 1, 2, 3, ...}
## Usage: is_non_negative <number>
function is_non_negative() {
    [[ "$1" =~ ^[+]?[0-9]+$ ]]
}

## Tests if the parameter represents a valid non-positive integer number: {0, -0, -1, -2, -3, ...}
## Usage: is_non_positive <number>
function is_non_positive() {
    [[ "$1" =~ ^-[0-9]+$ || "$1" =~ ^[-]?0+$ ]]
}

## Tests if the parameter represents a valid negative integer number: {-1, -2, -3, ...}
## Usage: is_negative <number>
function is_negative() {
    [[ $1 =~ ^-[0-9]+$ && ! "$1" =~ ^[-]?0+$ ]]
}

## Tests if the parameter represents a valid integer number: {..., -2, -1, 0, 1, 2, ...}
## Usage: is_integer <number>
function is_integer() {
    [[ "$1" =~ ^[-+]?[0-9]+$ ]]
}

## Tests if the parameter represents a valid decimal number
## Usage: is_decimal <number>
function is_decimal() {
    [[ "$1" =~ ^[-+]?[0-9]*(\.[0-9]*)?$ ]]
}

## Tests if the first parameter is equal to one of the following parameters.
## Usage: is_in <value> <option1> [<option2> ...]
function is_in() {
    if [[ $# -lt 2 ]]; then
        error "The function is_in() requires at least 2 arguments: the value to test and at least one valid option."
        return 2
    fi

    local sought="$1"; shift
    local v
    for v in "$@"; do
        [[ "$sought" == "$v" ]] && return 0
    done
    return 1
}

## Tests if the parameter represents a valid file pattern and returns a list of matching files.
## Usage: list_of_files <file_pattern>
function list_of_files() {
    if [[ $# -lt 1 ]]; then
        error "The function list_of_files() requires at least one parameter: the file pattern."
        return 2
    fi

    local pattern="$1"

    # by default, if a glob pattern does not match any files, it expands to an empty string instead of the default: to leave
    # the pattern unchanged, e.g. ${artifacts_dir}/results/*-report.json - we don't want that
    shopt -s nullglob
    shopt -s globstar || true
    # shellcheck disable=SC2206
    local list=($pattern)
    shopt -u nullglob
    shopt -u globstar || true
    printf "%s" "${list[*]}"
    return 0
}

## Displays a prompt, followed by "Press any key to continue..." and returns only after the script user
## presses a key. If there is defined variable $quiet with value "true", the function will not display prompt and will
## not wait for response.
function press_any_key() {
    if [[ "$quiet" != true ]]; then
        read -n 1 -rsp 'Press any key to continue...' >&2
        echo
    fi
    return 0
}

## Asks the script user to respond yes or no to some prompt. If there is a defined variable $quiet with
## value "true", the function will not display the prompt and will assume the default response or 'y'.
## Parameter 1 - the prompt to confirm.
## Parameter 2 - the default response if the user presses [Enter]. When specified should be either 'y' or 'n'. Optional.
## Outputs the result to stdout as 'y' or 'n'.
function confirm() {
    if [[ -z "$1" ]]; then
        error "The function confirm() requires at least one parameter: the prompt."
        exit 2
    fi
    if [[ -n "$2" && ! "$2" =~ ^[ynYN]$ ]]; then
        error "If a default response parameter is specified for the function confirm(), it must be either 'y' or 'n'"
        exit 2
    fi

    local default
    local prompt="$1"

    default=$(to_lower "${2:-y}")

    if [[ "$quiet" == true ]]; then
        printf '%s' "$default"
        return 0
    fi

    local suffix

    if [[ "$default" == y ]]; then
        suffix="[Y/n]"
    else
        suffix="[y/N]"
    fi

    local response
    while true; do
        read -rp "$prompt $suffix: " response >&2
        response=${response:-$default}
        response=${response,,}
        if [[ "$response" =~ ^[yn]$ ]]; then
            printf '%s' "$response"
            return 0;
        fi
        echo "Please enter y or n." >&2
    done
}

## Displays a prompt and a list of options to the script user and asks them to choose one of the options.
## Parameter 1 - the prompt to display before the options
## Parameter 2 - the text of the first option
## Parameter 3 - the text of the second option.
## ... - etc.
## The first option is the default one.
## The result will be printed in stdout as the number of the chosen option.
## The function will exit with code 2 if less than 3 parameters are specified.
function choose() {
    if [[ $# -lt 3 ]]; then
        echo "The function choose() requires 3 or more arguments: a prompt and at least two choices." >&2;
        return 2;
    fi

    local prompt=$1; shift
    local options=("$@")

    if [[ "$quiet" == true ]]; then
        printf '1'
        return 0
    fi

    echo "$prompt" >&2
    local -i i=1
    for o in "${options[@]}"; do
        if [[ $i -eq 1 ]]; then
            echo "  $i) $o (default)" >&2
        else
            echo "  $i) $o" >&2
        fi
        ((i++))
    done

    local -i selection=1
    while true; do
        read -rp "Enter choice [1-${#options[@]}]: " selection
        selection=${selection:-1}
        [[ $selection = 0 ]] && selection=1
        if [[ $selection =~ ^[1-9][0-9]*$ && $selection -ge 1 && $selection -le ${#options[@]} ]]; then
            printf '%d' "$selection"
            return 0
        fi
        echo "Invalid choice: $selection" >&2
    done
    return 0
}

## Gets the result of executing JSON query expression on YAML file.
## Requires "jq" and "yq" to be installed!
## Param 1 - the JSON query expression to execute
## Param 2 - the YAML file
## Return 0 if the result is not null and not empty; otherwise 1
## The query result will be output to stdout.
function get_from_yaml()
{
    if [[ $# -lt 2 ]]; then
        echo "The function get_from_yaml() requires two parameters: the query and the yaml file name." >&2
        return 2
    fi

    local query="$1";
    local file="$2"
    if [[ ! -s "$file" ]]; then
        echo "The file '$file' is empty or does not exist." >&2
        return 1
    fi
    local r
    r=$(yq eval "$query" "$file") || return 1
    [[ "$r" == "null" ]] && return 1
    printf '%s' "$r"
    return 0
}

## Gets a user ID and a password from the script user. In the end the script will ask the user to
## confirm their entries.
## Parameter 1 - the prompt for getting the user ID. Default "User ID: "
## Parameter 2 - the prompt for getting the password. Default "Password: "
## Parameter 3 - the prompt to confirm that the input is correct. If empty, the function will not ask the user to confirm
## their input.
## The user ID and the password will be held in $return_userid and $return_passwd until the next invocation of the
## function.
function get_credentials() {
    local promptUserID=${1:-"User ID: "}
    local promptPassword=${2:-"Password: "}
    local promptConfirm=$3
    userid=""
    passwd=""
    [[ "$quiet" == true ]] && printf "%s:%s" "$userid" "$passwd" && return 0
    while [[ -z $userid  &&  -z $passwd ]]; do
        read -rp "$promptUserID" userid >&2
        read -rsp "$promptPassword" passwd >&2
        echo >&2
        if [[ -n "$promptConfirm" ]] && confirm "$promptConfirm"; then
            printf "%s:%s" "$userid" "$passwd"
            exit 0
        else
            userid=""
            passwd=""
        fi
    done
}

# scp_retry tries the SSH copy command up to three times with timeout of 10sec timeout between retries.
# Parameters - the same parameters as the scp command, this is there must be at least 2 arguments.
# If the operation is successful it will set $return_copied to 'true' until the next invocation.
function scp_retry() {
    local -i try=0
    local -i retry_after=10
    while true; do
        if execute scp "$@"; then
            printf 'true'
            return 0
        fi
        if ((try < 3)); then
            echo "  - will try scp again in ${retry_after}sec..." >&2
            sleep "$retry_after"
        else
            break
        fi
        ((try++))
    done

    echo "FAILED: scp $*" >&2
    return 1
}
