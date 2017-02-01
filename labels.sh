#!/bin/bash
#
# helper script to generate label data for docker image during building
#
awscli_latest_version() {
    PYPI_AWSCLI="https://pypi.python.org/pypi/awscli/json"
    curl -s --retry 5                \
        --retry-max-time 20          \
            $PYPI_AWSCLI             \
    | jq -r '.releases | keys | .[]' \
        2>/dev/null                  \
    | sort --version-sort            \
    | tail -1 || return 1
}

built_by() {
    local user="--UNKNOWN--"
    if [[ ! -z "${BUILD_URL}" ]]; then
        user="${BUILD_URL}"
    elif [[ ! -z "${AWS_PROFILE}" ]] || [[ ! -z "${AWS_ACCESS_KEY_ID}" ]]; then
        user="$(aws iam get-user --query 'User.UserName' --output text)@$HOSTNAME"
    else
        user="$(git config --get user.name)@$HOSTNAME"
    fi
    echo "$user"
}

git_uri(){
    git config remote.origin.url || echo 'no-remote'
}

git_ref(){
}
