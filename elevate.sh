#!/bin/bash

set -euo pipefail

function export_askpass_gui_prompt_for_sudo() {
    export SUDO_ASKPASS="$( which ssh-askpass )"
}

VAR_USER_NAME="${1}"
VAR_COMMAND_SCRIPT="${2}"

export_askpass_gui_prompt_for_sudo

sudo --askpass                              \
     --group ${VAR_USER_NAME}               \
     --user  ${VAR_USER_NAME}               \
     /bin/bash ${VAR_COMMAND_SCRIPT} ${@:3}
