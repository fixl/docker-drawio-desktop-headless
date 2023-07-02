ARG DRAWIO_DESKTOP_VERSION
FROM rlespinasse/drawio-desktop-headless:v${DRAWIO_DESKTOP_VERSION}

RUN apt-get update && apt-get dist-upgrade -y && apt-get install -y \
        make \
        bash \
        inotify-tools \
        entr \
        parallel \
    && rm -rf /var/lib/apt/lists/* \
    # For when user/group is set to non-root id
    && mkdir -p /.pki /.cache \
    && chmod 777 /.pki /.cache

COPY scripts/render.sh /usr/local/bin/render

RUN chmod +x /usr/local/bin/render

ENV XVFB_OPTIONS "-nolisten tcp -nolisten unix"
ENV XDG_CONFIG_HOME "/tmp/.config"

WORKDIR "/src"
