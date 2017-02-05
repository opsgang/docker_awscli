#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent:
# helper script to generate label data for docker image during building
#
# docker_build will generate an image tagged :candidate
#
# It is a post-step to tag that appropriately and push to repo

MIN_DOCKER=1.11.0
GIT_SHA_LEN=8
IMG_TAG=candidate

version_gt() {
    [[ "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1" ]]
}

valid_docker_version() {
    v=$(docker --version | grep -Po '\b\d+\.\d+\.\d+\b')
    if version_gt $MIN_DOCKER $v
    then
        echo "ERROR: need min docker version $MIN_DOCKER" >&2
        return 1
    fi
}

awscli_version() {
    _pypi_pkg_version 'awscli'
}

credstash_version() {
    _pypi_pkg_version 'credstash'
}

_pypi_pkg_version() {
    local pkg="$1"
    local uri="https://pypi.python.org/pypi/$pkg/json"
    curl -s --retry 5                \
        --retry-max-time 20 $uri     \
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

img_name(){
    (
        set -o pipefail;
        grep -Po '(?<=[nN]ame=")[^"]+' Dockerfile | head -n 1
    )
}

labels() {
    av=$(awscli_version) || return 1
    gu=$(git_uri) || return 1
    gs=$(git_sha) || return 1
    gb=$(git_branch) || return 1
    gt=$(git describe || echo "untagged")
    bb=$(built_by) || return 1

    cat<<EOM
    --label version=${av}_$(date +'%Y%m%d%H%M%S')
    --label opsgang.awscli_version=$av
    --label opsgang.build_git_uri=$gu
    --label opsgang.build_git_sha=$gs
    --label opsgang.build_git_branch=$gb
    --label opsgang.build_git_tag=$gt
    --label opsgang.built_by=$bb
EOM
}

# will create an image tagged 'candidate'
docker_build(){

    valid_docker_version || return 1

    labels=$(labels) || return 1
    n=$(img_name) || return 1

    docker build --no-cache=true --force-rm $labels -t $n:$IMG_TAG .
}

docker_build
