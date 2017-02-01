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

# built with the following additional labels:
#   opsgang.build_git_uri
#   opsgang.build_git_ref
#   opsgang.build_git_sha
#   opsgang.built_by
#   opsgang.awscli_version
