ARG DRAWIO_DESKTOP_VERSION
FROM rlespinasse/drawio-desktop-headless:v${DRAWIO_DESKTOP_VERSION}

RUN apt-get update && apt-get dist-upgrade -y && apt-get install -y \
        make \
        bash \
        inotify-tools \
        entr \
        parallel \
    && rm -rf /var/lib/apt/lists/*

COPY scripts/render.sh /usr/local/bin/render

RUN chmod +x /usr/local/bin/render

ENV XVFB_OPTIONS "-nolisten tcp -nolisten unix"
ENV XDG_CONFIG_HOME "/tmp/.config"

WORKDIR "/src"
