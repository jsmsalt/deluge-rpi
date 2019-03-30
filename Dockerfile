FROM alpine:3.9

MAINTAINER Jose Morales <jsmsalt@gmail.com>

# Environment variables.
ENV USERNAME=deluge \
	PASSWORD=deluge

# Setup a user.
RUN adduser --system -u 1000 deluge

# Full installation.
RUN echo "********** [INSTALL DEPENDENCIES] **********" \
	&& echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
	&& apk add --update --no-cache \
		deluge@testing \
		tzdata \
	\
	\
	&& echo "********** [CLEAN UP] **********" \
	&& rm -rf \
		/tmp/* \
		/var/tmp/* \
		/var/cache/apk/* \
		/root/.cache/* \
		/var/cache/*

# Expose the deluge control port and the web UI port.
EXPOSE 58846 8112

# Define code volume.
VOLUME /downloads /config

# Add the start script.
ADD start.sh /start.sh
RUN chmod +x /start.sh

# Run the start script on boot.
CMD ["/start.sh"]