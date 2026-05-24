---
layout: default
title: FAQ
nav_order: e
---

# Frequently Asked questions
{: .no_toc }

1. TOC
{:toc}

### What is a container?

A container is like a "box" that contains an entirely self-sufficient software stack. You can think of containers as fully packaged apps that, once built, can be transferred from one machine to another and will run exactly the same code, byte by byte. If you are familiar with virtual machines (VMs), containers are a bit like that, but much more lightweight, and starting them up is a *lot* faster. For that reason, they have become the standard in the tech industry to run almost everything in production.

The `gds_env` project provides a container ([`gds`](../stacks/gds)) which allows you to run a JupyterLab instance seamlessly without having to install anything else beyond Docker. The container includes JupyterLab, all the Python and R geospatial packages, and all the underlying dependencies — no manual installation required.

### Why is `gds_env` not a desktop app?

A modern software stack for (geospatial) scientific computing is a very complex and delicate construction. For the final product (e.g. JupyterLab) to work, several pieces need to be in the right place and in the right shape. For example, several Python and R geospatial libraries (e.g. `geopandas` or `sf`) rely on libraries for much of the heavy lifting (e.g. GDAL). These libraries are written in low-level languages such as C/C++ and need to be compiled with the appropriate options, which are tailored to the operating system, version of other packages, etc. This is already complicated enough to expect beginners to do it. Furthermore, even if originally the stack is installed correctly on a desktop, this can change if new libraries are installed subsequently, breaking the install of the earlier libraries.

Containers help in this context because they offload all the technical details of an install away from the end-user. Once the container is built and works correctly, it can be transferred to any other platform that has Docker installed and it will run just as it does on the original setup. No hairy installation guides. Just pulling the container with one command.

Building a container instead of a desktop app has additional benefits. The range of setups in which it can be run is wider. A container can be run on almost any laptop; but it can also be run on a server, a supercomputer, or in the cloud. This streamlines how a user can learn, prototype and deploy analysis. You can learn Python on your laptop, then apply what you learn on a research project and, when the data or requirements of the analysis grow too big for your laptop, move it to a server or the cloud without intermediate install headaches. If it works on your laptop, it will work anywhere.

### Do I need to build my own `gds_env` to be able to run it?

No. Every release, a new version of the `gds_env` is built and published to Docker Hub (check out the [list of releases](https://github.com/darribas/gds_env/releases) for more details). You can use those containers directly without having to build them yourself — just follow the [Docker install guide](../guides/docker_install).

### Can `gds_env` be installed and run without advanced technical skills?

Yes! In fact, this is one of the main goals of the project. Building a container can be tricky but, once someone has built it, installing it is much more straightforward. The idea of the `gds_env` project is to provide pre-built containers that give access to state-of-the-art software for Geographic Data Science and that can be installed and run by non-technical audiences.

If you are an end-user, the [Docker install guide](../guides/docker_install) walks you through the process step by step.

### Is the `gds_env` suitable for teaching environments?

Absolutely! One of the original reasons why the project got off the ground was the need, within the [Geographic Data Science Lab](https://www.liverpool.ac.uk/geographic-data-science/), to deploy complex scientific stacks for Python and R to students who are learning to code for the first time. If you are using the `gds_env` to help you teach, we would love to hear from you — feel free to drop Dani a line at `D.Arribas-Bel [at] liverpool.ac.uk`.

### Who is behind the `gds_env`?

The `gds_env` was originally an idea by [Dani Arribas-Bel](https://darribas.org) ([`@darribas`](https://twitter.com/darribas)) to manage his own scientific software installs for research and teaching (mostly at the [Geographic Data Science Lab](https://www.liverpool.ac.uk/geographic-data-science/)). The project has grown over time and a few more people have contributed. You can see the [full list of contributors](https://github.com/darribas/gds_env/graphs/contributors) and if you would like to get involved, see the [guidance on contributing](../contributing).
