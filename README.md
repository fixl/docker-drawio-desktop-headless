# Draw.io Desktop Headless Image

[![Build Container](https://github.com/fixl/docker-drawio-desktop-headless/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/fixl/docker-drawio-desktop-headless/actions/workflows/build.yml)
[![version](https://fixl.github.io/docker-drawio-desktop-headless/version.svg)](https://github.com/fixl/docker-drawio-desktop-headless/commits/main/)
[![size](https://fixl.github.io/docker-drawio-desktop-headless/size.svg)](https://github.com/fixl/docker-drawio-desktop-headless/commits/main/)
[![Docker Pulls](https://img.shields.io/docker/pulls/fixl/drawio-desktop-headless)](https://hub.docker.com/r/fixl/drawio-desktop-headless)
[![Docker Stars](https://img.shields.io/docker/stars/fixl/drawio-desktop-headless)](https://hub.docker.com/r/fixl/drawio-desktop-headless)

A Docker container based on [docker-drawio-desktop-headless](https://github.com/rlespinasse/docker-drawio-desktop-headless) with
extra scripts for convenience.

This image can be used with [3 Musketeers](https://3musketeers.pages.dev/).

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
