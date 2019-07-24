FROM alpine:latest
LABEL maintainer=jon@jaggersoft.com

ARG SHA
ENV SHA=${SHA}

#RUN mkdir /etc/periodic/1min
#RUN sed -i '/^$/d' /etc/crontabs/root
#RUN echo '*	*	*	*	*	run-parts /etc/periodic/1min' >> /etc/crontabs/root

COPY pull   /etc/periodic/daily/
#COPY pull   /etc/periodic/1min/

# For testing
COPY cron-env    /home
COPY run-as-cron /home

# -f    foreground
# -d 8  log to stderr, log level 8 (default)
CMD [ "crond", "-f", "-d", "8" ]
