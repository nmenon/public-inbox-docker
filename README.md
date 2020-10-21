Introduction
============

* ~700 MB diskspace for a specific package combination install is something I
  am willing to pay in 2020.
* public-inbox needs a weird set of packages and configs
* Upstream [documentation](https://public-inbox.org/public-inbox.git/tree/INSTALL) is [sketchy](https://lwn.net/Articles/748184/)
* I think public-inbox is cool and MOAR people need to use it.

Proxy Setup Step
================

If you are working in an environment, where http proxy is necessary,
update the files in proxy-configuration to match up with what your
environment needs are With out this, ofocourse, you cannot install the
various packages needed to build up the docker image

Update Dockerfile to fixup the lines that use proxy

Versions of packages
====================

Update the Makefile to pick up the various latest tags and
versions of the apps needed

Building the docker image
=========================

Dependency to build docker is:
* docker.io
* proxy settings for docker to pull in required images

Build commands:
* make : build image public-inbox
* make clean : I strongly recommend NOT to use my version if you have other docker images running in your system.
* make deploy REPO=xyz : Deploy image to an docker registry

Using Docker Image
==================

* If you want to want to use prebuild version deployed in Docker-hub

```
docker pull nishanthmenon/public-inbox

```

* If you want to run the httpd

```
docker run -it --rm -p  8080:8080 -v /tmp:/tmp public-inbox /usr/local/bin/public-inbox-httpd
```

voila you have localhost:8080 a quick taste of what is here.
