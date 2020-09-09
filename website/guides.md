---
layout: default
title: Guides
nav_order: c 
has_children: true
---

# Guides

This section illustrates how to build, install and deploy the `gds_env` in a variety of contexts. At the core of all of them are the images described in [Stacks](../stacks), and each can be deployed through these delivery channels.

Currently, two approaches are supported: Docker and Virtualbox. If available,
the recommended way is through Docker, which is a more lightweight solution
and can be more efficient and scalable. However, Docker is not always an
option (e.g. some versions of Windows or systems for users without 
administrative rights). For these cases, a more widely available option is a
full-fledge virtual machine such as VirtualBox.

The guides cover two different user scenarios: *build* and *install*. Install
guides are geared towards end users who want to run the one of the [`gds_env`
flavours](../stacks) on their machine; build guides are designed to document
the process used to create available images and hence will probably be more
useful for more advanced users or administrators (e.g. lecturers)who want to
prepare a new image for deployment.

