FROM python:2.7-alpine

RUN apk add terraform --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
        && \
        apk -v --update add \
               jq \
               perl \
               bash \
               coreutils \
               binutils \
               curl \
               git \
               gettext \
               wget \
        && \
               apk add github-cli --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
        && \
            echo "Installing Miller" \
                    && export tmp_dir="$(mktemp -d)" \
                    && curl -L https://github.com/johnkerl/miller/releases/download/v6.0.0/miller_6.0.0_linux_386.tar.gz -o "$tmp_dir"/mlr.tgz \
                    && tar xvzf "$tmp_dir"/mlr.tgz -C "$tmp_dir" \
                    && mv "$tmp_dir"/mlr /usr/local/bin/mlr \
                    && chmod +x /usr/local/bin/mlr \
                    && /usr/local/bin/mlr --help \
                    && rm -rf "$tmp_dir" \
        && \
            echo "Installing AWS CLI v2.x" \
                   && export GLIBC_VER=2.31-r0 \
                   && curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
                   && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk \
                   && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk \
                   && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-i18n-${GLIBC_VER}.apk \
                   && apk add --no-cache \
                       glibc-${GLIBC_VER}.apk \
                       glibc-bin-${GLIBC_VER}.apk \
                       glibc-i18n-${GLIBC_VER}.apk \
                   && /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8 \
                   && curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
                   && unzip awscliv2.zip \
                   && aws/install \
                   && rm -rf \
                       awscliv2.zip \
                       aws \
                       /usr/local/aws-cli/v2/current/dist/aws_completer \
                       /usr/local/aws-cli/v2/current/dist/awscli/data/ac.index \
                       /usr/local/aws-cli/v2/current/dist/awscli/examples \
                       glibc-*.apk \
                   && find /usr/local/aws-cli/v2/current/dist/awscli/botocore/data -name examples-1.json -delete \
                   && apk --no-cache del \
                       binutils \
                       curl \
        && \
            echo "Cleaning up..." \
            && rm /var/cache/apk/*

WORKDIR /project

ENTRYPOINT []
