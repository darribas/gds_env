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

A container is like a "box" that contains a entirely self-sufficient software stack. You can think of containers as fully packaged apps that, once built, can be transferred from one machine to another and will run exactly the same code, byte by byte. If you are familiar with virtual machines (VMs), containers are a bit like that, but much more lightweight, and starting them up is a *lot* faster. For that reason, they have become the standard in the tech industry to run almost everything in production.

The `gds_env` project provides three main containers ([`gds_py`](../stacks/gds_py), [`gds`](../stacks/gds) and [`gds_dev`](../stacks/gds_dev)) which allow you to run a JupyterLab instance seamlessly without having to install anything else. In this case, the container includes Jupyter Lab and all the packages each stack includes, but also all the plugins, additional dependencies and other requirements that you would need to install to be able to run the libraries you want to successfully.

### Why is `gds_env` not a desktop app?

A modern software stack for (geospatial) scientific computing is a very complex and delicate construction. For the final product (e.g. JupyterLab) to work, several pieces need to be in the right place and in the right shape. For example, several Python and R geospatial libraries (e.g. `geopandas` or `sf`) rely on libraries for much of the heavy lifting (e.g. GDAL). These libraries are written in low-level languages such as C/C++ and need to be compiled with the appropriate options, which are tailored to the operating system, version of other packages, etc. This is already complicated enough to expect beginners to do it. Furthermore, even if originally the stack is installed correctly on a desktop, this can change if new libraries are installed subsequently, breaking the install of the earlier libraries. This is not fun, and no end-user should have to deal with this just because they want to make the most of modern geospatial software. 

Containers help in this context because the offload all the technical details of an install away from the end-user. Once the container is built and works correctly, it can be transferred to any other platform that with Docker (or Virtualbox) installed and it will run just as it does on the original setup. No hairy installation guides. Just flashing the container with one command. 

Building a container instead of a desktop app has additional benefits. The range of setups in which it can be run is wider. A container can be run on almost any laptop; but it can also be run on a server, a super-computer, or in the cloud in several forms. This streamlines a lot how a user can learn, protoype and deploy analysis. You can learn Python on your laptop, then apply what you learn on a research project and, when the data or requirements of the analysis grow too big for your laptop, move it to a server or the cloud without intermediate install headaches. If it works on your laptop, it will work anywhere.

### Why several stacks? Why not just one?

Containers are great because they package up everything you need to run an app, but this can take storage. Furthermore, many usecases do not require a full stack of Python, R and development tools. To be able to be a bit more nimble and provide smaller footprints for use cases that do not require the entire list of software packages, the `gds_env` is split into three, incremental, stacks. 

It is important to note that the [stacks](../stacks) are layered on top of each other. This means that if you install the three of them, you will only really need the space of the largest one ([`gds_dev`](../stacks/gds_dev)), as Docker is smart enough to combine layers from different containers without repetition.

### Can `gds_env` be installed and run without advanced technical skills?

Yes! In fact, this is one of the main goals of the project. Building a container can be tricky but, once someone has built it, installing it is much more straightforward. The idea of the `gds_env` project is to provide built containers, that provide access to state-of-the-art software for Geographic Data Science and that can be installed and run by non-technical audiences.

If you are an end-user, we provide guides to run `gds_env` containers on [Docker](../guides/docker_install) and [Virtualbox](../guides/virtualbox_install). If you are a more advanced developer and want to build and deploy your own containers, we also provide guides for [Docker](../guides/docker_build), [Virtualbox](../guides/virtualbox_build) and [Vagrant](../guides/vagrant_build).

### Do I need to build my own `gds_env` to be able to run it?

No. Every six months, a new version of the `gds_env` is built and released (check out the [list of releases](https://github.com/darribas/gds_env/releases) for more details). You can use those containers directly without having to build them yourself. Instead, you can just install and run them on [Docker](../guides/docker_install) or [Virtualbox](../guides/virtualbox_install).

### Is the `gds_env` suitable for teaching environments?

Absolutely! One of the original reasons why the project got off the ground was the need, within the [Geographic Data Science Lab](https://www.liverpool.ac.uk/geographic-data-science/) to deploy complex scientific stacks for Python and R to students who are learning to code for the first time. If you are using the `gds_env` to help you teach Python and R, we would love to hear from your experiences! Feel free to drop Dani a line at `D.Arribas-Bel [at] liverpool.ac.uk`.

### Can I run the `gds_env` on a machine without administrative rights?

Yes. Docker does require administrative priviledges on the user to run containers. However, if your environment does not allow this (e.g. machines managed by universities or employers), you can run them on Virtualbox (see the [guide to install on Virtualbox](../guides/virtualbox_install)). Alternatively, if you are a bit more tech savvy, you can try [Syngularity](../https://sylabs.io/), which is a project that allows you to run containers on Linux without administrative priviledges.

### My Windows Laptop does not support Docker. Can I still run `gds_env`?

Yes. Virtualbox is a virtualisation tool that can be installed on any recent version of Windows (XP and above) and on almost any other platform. Please see the guide to [install the `gds_env` using Virtualbox](../guides/virtualbox_install).

### Who is behind the `gds_env`

The `gds_env` was originally an idea by [Dani Arribas-Bel](https://darribas.org) ([`@darribas`](https://twitter.com/darribas)) to manage his own scientific software installs for research, and his teaching (mostly at the [Geographic Data Science Lab](https://www.liverpool.ac.uk/geographic-data-science/). However, the project has grown a bit and now a few more people have contributed. You can have a look at the [full list of contributors](https://github.com/darribas/gds_env/graphs/contributors) and if you would like to get involved, see the [guidance on contributing](../contributing). It'd be terrific to have you on board!
