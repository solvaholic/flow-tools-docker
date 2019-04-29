# flow-tools Docker image

While working through [Michael W. Lucas'](https://mwl.io/) book [_Network Flow Analysis_, available from no starch press](https://nostarch.com/networkflow), I want to use the latest version of `flow-tools`.

I had trouble finding a readily available package for it so I built it on Alpine Linux in this Docker container.

In case you, too, want to use `flow-tools` - here ya go!

To run `flow-tools` with your local `var-db-flows` directory:

```
docker run --rm -it -v $(realpath .)/var-db-flows:/var/db/flows solvaholic/flow-tools:latest
```

## This Repository

This repository contains the source of the following Docker images:

- `solvaholic/flow-tools`: Includes flow-tools 0.68.5.1 to capture and report network flow (netflow) data.

## `docker build`

To build this image you'll need a copy of [`flow-tools-0.68.5.1.tar.bz2`](https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/flow-tools/flow-tools-0.68.5.1.tar.bz2) so that's the first step. Download the image then `docker build` however you normally would.

For example:

```
curl -O https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/flow-tools/flow-tools-0.68.5.1.tar.bz2
docker build --rm -t flow-tools .
```

## `docker run`

By default `flow-capture` will run in this container. It listens on UDP port 5678, and you can map that to whichever port you and your OS would like.

In addition to mapping the port, tell `docker run` which path to make available at the container's `/var/db/flows`.

To run the container and get your shell prompt back:

```
flowport=5678
flowdir="$(realpath .)/var-db-flows"
docker run -d -v ${flowdir}:/var/db/flows -p ${flowport}:5678/udp flow-tools
```

## `flow-cat`

You could run `flow-tools` on your workstation or in another container to analyze the flows you've recorded. You could also log into the running container and report on them there:

```
docker exec -it flow-tools-container /bin/sh
```

If you already know what to do with `flow-tools` then you're ready to go. If you're just getting started like me, though, then get a copy of [_Network Flow Analysis_](https://nostarch.com/networkflow) and dig in!

Here are the things I checked first, once I had some data:

```
myflows="$(ls /var/db/flows/*/*/*/ft-*)"
mylocal="10.0.0"

# Top 10 sources:
echo -e "\nMost frequent sources:\n"
flow-cat ${myflows} | flow-print | awk '{print $1}' | grep ${mylocal} | sort | uniq -c | sort -nr | head

# Top 10 destinations:
echo -e "\nMost frequent destinations:\n"
flow-cat ${myflows} | flow-print | awk '{print $2}' | grep -v ${mylocal} | sort | uniq -c | sort -nr | head
```

## Copyright?

Building this Dockerfile I came across just one license or copyright notice you may not see the way you're going. Since in my head building this image, or downloading it from a registry, will essentially redistribute `flow-tools` I want to be sure you find this one, too. Here's the `flow-tools` COPYING notice:

```
$ curl -s https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/flow-tools/flow-tools-0.68.5.1.tar.bz2 | tar xjO --wildcards "*/COPYING"
/*
 * Copyright (c) 2001 Mark Fullmer and The Ohio State University
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 *      $Id: COPYING,v 1.1 2001/02/11 01:09:37 maf Exp $
 */
```
