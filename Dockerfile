FROM gliderlabs/alpine:3.4
MAINTAINER jinal--shah <jnshah@gmail.com>
LABEL \
      name="opsgang/awscli" \
      vendor="sortuniq"     \
      version="1.0.0"       \
      description="... alias docker-run to 'aws' and run as if aws cli" \

COPY alpine_build_scripts /alpine_build_scripts

RUN chmod a+x /alpine_build_scripts/*.sh       \
    && /alpine_build_scripts/install_awscli.sh \
    && rm -rf /var/cache/apk/* /alpine_build_scripts 2>/dev/null

CMD ["aws"]
ENTRYPOINT ["aws"]

# built with additional labels:
# VER=$(grep -Po '(?<=version=")[^"]+' Dockerfile)
# NAME=$(grep -Po '(?<=name=")[^"]+' Dockerfile)
#  . ./labels.sh
#  docker build \
#   --no-cache=true --force-rm \
#   --label opsgang.awscli_version=$(awscli_version) \
#   --label opsgang.build_git_uri=$(git_uri)
#   --label opsgang.build_git_ref=$(git_ref)
#   --label opsgang.build_git_sha=$(git_sha)
#   --label opsgang.built_by=$(built_by)
#   -t $NAME:$VER .
