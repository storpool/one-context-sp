# OpenNebula Contextualization Scripts

Copyright (C) 2019-2020 StorPool

This package provides a replacement package for one-context by OpenNebula.
More information about the replaced package (by OpenNebula) can be found here:
https://github.com/OpenNebula/addon-context-linux

This replacement resolves number of issues with the original contextualization
package. The main problem with the original package is that change in one
parameter causes all configuration setting to be reset.  Some parts were
rewritten from scratch, others have small or no modifications from the original
package.

The scripts in this package run on the guest VM, and are started on VM
instantiation, on every reboot and on VM reconfiguration, when CONTEXT CD is
ejected and re-inserted.

The behavior differs from the original context scripts. The `one-contexd`
service detects the type of event (`INIT`, `BOOT`, `CONF`) and passes it as an
environment variable `CONTEXT_EVENT` to the worker scripts. The scripts behave
differently depending on the event type and the script purpose.

Another major difference is that only scrips starting with `loc-*` and `net-*`
are executed. `loc-*` scripts are executed before starting the network service,
`net-*` are executed after network service has been started. Scripts are
located at `/etc/one-context.d/`.

For more information see src/usr/share/doc/one-context/README.md

## Download

Latest versions can be downloaded from https://github.com/storpool/one-context-sp

## Install

::

    yum install http://repo.storpool.com/public/one-context-sp/centos/7/noarch/Packages/one-context-sp-release-1.0-0.el7.noarch.rpm
    yum install one-context-sp

## Tested platforms

List of tested platforms only:

| Platform                        | Versions                               |
|---------------------------------|----------------------------------------|
| CentOS                          | 7                                      |

(the packages might work on other versions or flavours, but those aren't tested)

## Build own package

### Build Requirements

* **Linux host**
* **Ruby** >= 1.9
* gem **fpm** >= 1.10.0
* **dpkg utils** for deb package creation
* **rpm utils** for rpm package creation

### Steps

The script `generate.sh` is able to create all package types and can be
configured to include more files in the package or change some of
its parameters. Package type and content are configured by the environment variable
`TARGET`, the corresponding target must be defined in `target.sh`. Target
describes the package format, name, dependencies, and files. Files are
selected by the tags. Set of required tags is defined for the target
(in `targets.sh`), each file has a list of corresponding tags right in its
filename (divided by the regular name by 2 hashes `##`, dot-separated).

Package name or version can be overridden by env. variables `NAME` and `VERSION`.

Examples:

```
$ TARGET=deb ./generate.sh
$ TARGET=el7 NAME=my-one-context ./generate.sh
$ TARGET=alpine ./generate.sh
$ TARGET=freebsd VERSION=5.7.85 ./generate.sh
```

NOTE: The generator must be executed from the same directory it resides.

Check `generate.sh` for general package metadata and `targets.sh` for the list
of targets and their metadata. Most of the parameters can be overriden by
the appropriate environment variable.

## Development

### Repository structure

All code is located under `src/` and structure follows the installation
directory structure. Files for different environments/targets are picked
by the tag, tags are part of the filename separated from the installation
name by 2 hashes (`##`). Tags are dot-separated.

Examples:

* `script` - non-tagged file for all targets
* `script##systemd` - file tagged with **systemd**
* `script##systemd.rpm` - file tagged with **systemd** and **rpm**

### Contextualization scripts

Contextualization scripts, which are executed on every boot and during the
reconfiguration, are located in `src/etc/one-context.d/`. Seen notesi in the
beginning when scripts are executed. Scripts are divided into following 2
parts:

* local - pre-networking, prefixed with `loc-`
* post-networking, prefixed with `net-`


## License

Copyright StorPool 2019,
Copyright 2002-2019, OpenNebula Project, OpenNebula Systems (formerly C12G Labs)

Licensed under the Apache License, Version 2.0 (the "License"); you may
not use this file except in compliance with the License. You may obtain
a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
