#!/bin/bash

#set -x

TESTING=1

. ./common.sh

_check_argument_is_number 123 "this" || failed="$((++failed))"
_check_argument_is_number NotNumber "this" && failed="$((++failed))"

_check_argument_value 8 7 "this" || failed="$((++failed))"
_check_argument_value 1 7 "this" && failed="$((++failed))"

_check_argument_is_string "Hello" "this" || failed="$((++failed))"
_check_argument_is_string "Hello world" "this" && failed="$((++failed))"


failed="${failed:-0}"
echo "$failed"
exit "$failed"
