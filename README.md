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

Initialize the public-inbox submodule before building: git submodule update --init public-inbox.

Build commands:
* make : build image public-inbox
* make clean : I strongly recommend NOT to use my version if you have other docker images running in your system.
* make deploy REPO=xyz : Deploy image to an docker registry

Using Docker Image
==================

* If you want to want to use prebuild version deployed in:

github Container registry:

```
docker pull ghcr.io/nmenon/public-inbox

```

OR dockerhub:

```
docker pull nishanthmenon/public-inbox

```


* If you want to run the httpd

```
docker run -it --rm -p  8080:8080 -v /tmp:/tmp ghcr.io/nmenon/public-inbox /usr/local/bin/public-inbox-httpd
```

voila you have localhost:8080 a quick taste of what is here.

Wrappers and examples to get started:
------------------------------------
* [Wrapper scripts and cron wrappers for public-inbox](bin/README.md)
* [public-inbox and mbsync configurations](cfg/README.md)


Automated upstream refresh
==========================

Every Sunday at 08:00 UTC (and on manual dispatch), the workflow compares the highest stable public-inbox tag with the last successfully published tag and resolves upstream HEAD through its advertised symbolic branch, without assuming a branch name.

A new stable tag takes priority: build its exact submodule commit and publish the version without v plus latest. On Sunday/manual runs without a new tag, a changed upstream HEAD is built from the checked-out submodule and published as latest only; unchanged HEAD skips build and publish.

The tracked state file .github/public-inbox-upstream-state stores the last successfully published tag and the last scheduled/manual upstream HEAD separately from the gitlink. State and gitlink advance only after both registry publishes succeed, so failed runs retry; missing state bootstraps with a release build. On push-triggered runs, a newly published stable release takes priority; otherwise the workflow builds upstream HEAD and publishes latest only, even if HEAD is unchanged. Default-branch pushes preserve the weekly HEAD checkpoint; Sunday/manual runs advance it. The workflow uses the existing CR_PAT, DOCKER_USER, and DOCKER_TOKEN secrets.

The repository must allow GitHub Actions to push to the default branch; branch protection rules that block the workflow's GITHUB_TOKEN push prevent automatic gitlink updates. That push does not trigger another workflow run.
