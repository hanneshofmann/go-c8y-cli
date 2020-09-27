FROM alpine:3.11

RUN apk update \
    && apk add curl unzip bash bash-completion \
    && adduser -S c8yuser

WORKDIR /home/c8yuser

RUN curl -L https://www.powershellgallery.com/api/v2/package/PSc8y/1.3.0 -o c8y.zip \
    && unzip -p c8y.zip Dependencies/c8y.linux > /usr/bin/c8y \
    && chmod +x /usr/bin/c8y \
    && rm c8y.zip

USER c8yuser

RUN curl -L https://raw.githubusercontent.com/reubenmiller/go-c8y-cli/master/tools/c8y.profile.sh -o ~/c8y.profile.sh \
    && echo "source ~/c8y.profile.sh" >> ~/.bashrc

VOLUME [ "/home/c8yuser/.cumulocity" ]

ENTRYPOINT [ "/bin/bash" ]
