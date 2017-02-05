FROM gliderlabs/alpine:3.4
MAINTAINER jinal--shah <jnshah@gmail.com>
LABEL \
      name="opsgang/awscli" \
      vendor="sortuniq"     \
      description="... alias docker-run to 'aws' and run as if aws cli"

COPY alpine_build_scripts /alpine_build_scripts

RUN chmod a+x /alpine_build_scripts/*.sh       \
    && /alpine_build_scripts/install_awscli.sh \
    && rm -rf /var/cache/apk/* /alpine_build_scripts 2>/dev/null

CMD ["aws"]
ENTRYPOINT ["aws"]

# built with additional labels:
#
# version
# opsgang.awscli_version
# opsgang.credstash_version
# opsgang.jq_version
#
# opsgang.build_git_uri
# opsgang.build_git_sha
# opsgang.build_git_branch
# opsgang.build_git_tag
# opsgang.built_by
#
