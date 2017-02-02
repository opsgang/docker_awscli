#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent:
# helper script to generate label data for docker image during building
#

GIT_SHA_LEN=8

version_gt() {
    [[ "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1" ]]
}

valid_docker_version() {
    v=$(docker --version | grep -Po '\b\d+\.\d+\.\d+\b')
    if version_gt 1.12.0 $v
    then
        echo "ERROR: need min docker version 1.12.0" >&2
        return 1
    fi
}

awscli_version() {
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

git_sha(){
    git rev-parse --short=${GIT_SHA_LEN} --verify HEAD
}

git_branch(){
    r=$(git rev-parse --abbrev-ref HEAD)
    [[ -z "$r" ]] && echo "ERROR: no rev to parse when finding branch? " >&2 && return 1
    [[ "$r" == "HEAD" ]] && r="from-a-tag"
    echo "$r"
}

img_version(){
    (
        set -o pipefail;
        grep -Po '(?<=[vV]ersion=")[^"]+' Dockerfile | head -n 1
    )
}

img_name(){
    (
        set -o pipefail;
        grep -Po '(?<=[nN]ame=")[^"]+' Dockerfile | head -n 1
    )
}

labels() {
    cat<<EOM
    --label "opsgang.awscli_version=$(awscli_version)"
    --label "opsgang.build_git_uri=$(git_uri)"
    --label "opsgang.build_git_sha=$(git_sha)"
    --label "opsgang.build_git_branch=$(git_branch)"
    --label "opsgang.build_git_tag=$(img_version)"
    --label "opsgang.built_by=$(built_by)"
EOM
}

docker_build(){

    valid_docker_version || return 1

    labels=$(labels) || return 1
    n=$(img_name) || return 1
    v=$(img_version) || return 1

    docker build --no-cache=true --force-rm $labels -t $n:$v .
}

git_tag(){
    [[ -z "$TAG_INFO" ]] && echo "ERROR: define \$TAG_INFO" >&2 && return 1
    git tag -a $img_version -m "${TAG_INFO}" \
    && git push --tags
}

docker_build