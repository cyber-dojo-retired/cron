FROM cyberdojo/ruby-base:latest
LABEL maintainer=jon@jaggersoft.com

RUN apk add --no-cache jq

ARG SHA
ENV SHA=${SHA}

COPY src/pull   /etc/periodic/daily/

# -f    foreground
# -d 8  log to stderr, log level 8 (default)
CMD [ "crond", "-f", "-d", "8" ]
