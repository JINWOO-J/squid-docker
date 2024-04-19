#!/bin/bash
set -e

create_log_dir() {
    echo "Creating log directory..."
    mkdir -p ${SQUID_LOG_DIR}
    chmod -R 755 ${SQUID_LOG_DIR}
    chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_LOG_DIR}
}

create_cache_dir() {
    echo "Creating cache directory..."
    mkdir -p ${SQUID_CACHE_DIR}
    chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_CACHE_DIR}
}

create_squid_conf() {
    if [[ ! -f ${SQUID_CONF} ]]; then

        SQUID_CONF_DIR=$(extract_directory ${SQUID_CONF})

        if [[ ! -d ${SQUID_CONF_DIR} ]]; then
            mkdir -p ${SQUID_CONF_DIR}
        fi

        echo "Copying default config from '${SQUID_SAMPLE_CONF}' to '${SQUID_CONF}'"
        cp ${SQUID_SAMPLE_CONF} ${SQUID_CONF}
        if [ $? -eq 0 ]; then
            echo "Configuration file copied successfully."
            chown ${SQUID_USER}:${SQUID_USER} ${SQUID_CONF}
            if [ $? -ne 0 ]; then
                echo "Failed to change ownership of the configuration file."
                exit 1
            fi
        else
            echo "Failed to copy configuration file."
            exit 1
        fi
    else
        echo "Using existing configuration file."
    fi
}

create_squid_ssl_db(){
    SSL_DB_DIR="/var/lib/ssl_db"
    if [[ ! -d ${SSL_DB_DIR} ]]; then
        echo "Initailizing SSL database directory..."
        /usr/lib/squid/security_file_certgen -c -s ${SSL_DB_DIR} -M 4MB
        chown -R ${SQUID_USER}:${SQUID_USER} ${SSL_DB_DIR}
    fi
}

remove_pid_file() {
    echo "Checking for existing PID file..."
    PID_FILE="/var/run/squid.pid"
    if [[ -f ${PID_FILE} ]]; then
        echo "Removing existing PID file..."
        rm -f ${PID_FILE}
    fi
}

extract_directory() {
    local dir=$(dirname "$1")

    if [ "$dir" = "." ]; then
        echo ""
    else
        echo "$dir"
    fi
}


remove_pid_file
create_log_dir
create_cache_dir
create_squid_conf
create_squid_ssl_db


# allow arguments to be passed to squid
if [[ ${1:0:1} = '-' ]]; then
    EXTRA_ARGS="$@"
    set --
    elif [[ ${1} == squid || ${1} == $(which squid) ]]; then
    EXTRA_ARGS="${@:2}"
    set --
fi


# default behaviour is to launch squid
if [[ -z ${1} ]]; then
    if [[ ! -d ${SQUID_CACHE_DIR}/00 ]]; then
        echo "Initializing cache..."
        $(which squid) -N -f ${SQUID_CONF} -z
    fi

    echo "Starting squid ${SQUID_VERSION} ..."
    exec $(which squid) -f ${SQUID_CONF} -NYCd 1 ${EXTRA_ARGS}
else
    exec "$@"
fi
