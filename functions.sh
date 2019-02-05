#!/bin/bash

function ensure_existing_file() {
    local VAR_PATH_TO_FILE=${1}

    if [ ! -f ${VAR_PATH_TO_FILE} ];
    then
        echo "The directory $( realpath ${VAR_PATH_TO_FILE} ) does not exist."
        exit 1
    fi
}

function ensure_existing_directory() {
    local VAR_PATH_TO_DIRECTORY=${1}

    if [ ! -d ${VAR_PATH_TO_DIRECTORY} ];
    then
        echo "The directory $( realpath ${VAR_PATH_TO_DIRECTORY} ) does not exist."
        exit 1
    fi
}

function ensure_exising_environment_variable() {
    local VAR_NAME_OF_VARIABLE=${1}

    if [[ ! -v ${VAR_NAME_OF_VARIABLE} ]];
    then
        echo "No environment variable named ${VAR_NAME_OF_VARIABLE} was defined."
        exit 1
    fi
}

function export_environment_file() {
    local VAR_PATH_TO_ENV_FILE="${1}"

    ensure_existing_file ${VAR_PATH_TO_ENV_FILE}

    while IFS='' read -r VAR_LINE || [[ -n "${VAR_LINE}" ]];
    do
        if [ "${VAR_LINE}" = "" ]; then
            continue;
        fi
        if [[ ${VAR_LINE} != \#* ]]; then
            export "${VAR_LINE}"
        fi
    done < "${VAR_PATH_TO_ENV_FILE}"
}

function open_application_url_if_defined() {
    local VAR_NAME_OF_URL_ENVIRONMENT_VARIABLE="HOST_SERVICE_URL"

    echo -E "Opening URL ..."

    if [[ ! -v ${VAR_NAME_OF_URL_ENVIRONMENT_VARIABLE} ]];
    then
        echo -e "Opening URL ... $( __skipped )"
        exit 0
    fi
    
    local VAR_URL_TO_OPEN=${!VAR_NAME_OF_URL_ENVIRONMENT_VARIABLE}
    
    xdg-open "${VAR_URL_TO_OPEN}"

    echo -e "Opening URL ... $( __done )"
}

function prepare_local_environment() {
    echo -E "Preparing local environment ..."

    local VAR_HOST_PATH_TO_CONFIGURATION_DIR=${1}
    local VAR_HOST_NAME_OF_DOCKER_COMPOSE_FILE=${2}

    ensure_existing_directory ${VAR_HOST_PATH_TO_CONFIGURATION_DIR}

    local VAR_HOST_PATH_TO_ENV_FILE=${VAR_HOST_PATH_TO_CONFIGURATION_DIR}/host.env

    export_environment_file ${VAR_HOST_PATH_TO_ENV_FILE}

    local VAR_NAME_OF_SERVICE_NAME_ENVIRONMENT_VARIABLE="HOST_SERVICE_NAME"

    ensure_exising_environment_variable ${VAR_NAME_OF_SERVICE_NAME_ENVIRONMENT_VARIABLE}

    local VAR_HOST_PATH_TO_DOCKER_COMPOSE_FILE=${VAR_HOST_PATH_TO_CONFIGURATION_DIR}/docker-compose/${!VAR_NAME_OF_SERVICE_NAME_ENVIRONMENT_VARIABLE}/${VAR_HOST_NAME_OF_DOCKER_COMPOSE_FILE}

    ensure_existing_file ${VAR_HOST_PATH_TO_DOCKER_COMPOSE_FILE}

    export HOST_PATH_TO_DOCKER_COMPOSE_FILE=${VAR_HOST_PATH_TO_DOCKER_COMPOSE_FILE}

    echo -e "Preparing local environment ... $( __done )"
}

function __done() {
    echo "\033[0;32mdone\033[0m"
}

function __error() {
    echo "\033[0;31merror\033[0m"
}

function __skipped() {
    echo "\033[0;33mskipped\033[0m"
}
