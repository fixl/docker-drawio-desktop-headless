# Draw.io Desktop Headless Image

[![pipeline status](https://gitlab.com/fixl/docker-drawio-desktop-headless/badges/master/pipeline.svg)](https://gitlab.com/fixl/docker-drawio-desktop-headless/-/pipelines)
[![version](https://fixl.gitlab.io/docker-drawio-desktop-headless/version.svg)](https://gitlab.com/fixl/docker-drawio-desktop-headless/-/commits/master)
[![size](https://fixl.gitlab.io/docker-drawio-desktop-headless/size.svg)](https://gitlab.com/fixl/docker-drawio-desktop-headless/-/commits/master)
[![Docker Pulls](https://img.shields.io/docker/pulls/fixl/drawio-desktop-headless)](https://hub.docker.com/r/fixl/drawio-desktop-headless)
[![Docker Stars](https://img.shields.io/docker/stars/fixl/drawio-desktop-headless)](https://hub.docker.com/r/fixl/drawio-desktop-headless)

A Docker container based on [docker-drawio-desktop-headless](https://github.com/rlespinasse/docker-drawio-desktop-headless) with
extra scripts for convenience.

This image can be used with [3 Musketeers](https://3musketeers.io/).

## Build the image

```bash
make build
```

## Inspect the image

```bash
docker inspect --format='{{ range $k, $v := .Config.Labels }}{{ printf "%s=%s\n" $k $v}}{{ end }}' fixl/drawio-desktop-headless:latest
```

## Usage

This image contains a `render` script that allows you to render all `*.drawio` files recursively
within a directory structure.

Example:
```
render -o output -b . -w
```

The main driver for this container is to conveniently render Draw.io diagrams for my [Blog] and use
[Hugo's] auto-reload during development.

[Blog]: https://fixl.info
[Hugo's]: https://gohugo.io/

## Changes

See what's changed between releases: https://github.com/rlespinasse/docker-drawio-desktop-headless/releases
