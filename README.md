# OpenNebula Linux VM Contextualization

## Description

This addon providesa replacement package for one-context by OpenNebula. This
replacement resolves the number of issues with the original contextualization
package. Some of the code is rewritten from scratch, another is used with
littl or no modifications from the original packahe.

The scripts in this package run on the guest VM, and are started on VM
instantination, on every reboot and on VM reconfigurstion, when CONTEX CD is
ejected and re-inserted.

The behaviour differs from the original context scripts. The `one-contexd`
service detects the type of event (INIT, BOOT, CONF) and pass it as
environment varriable CONTEXT_EVENT to the worker scripts. The scripts behave
differently depending on the event type and their purpose but the general rule
is:

  - on INIT, all existing configuration in the OS is cleared and new clean
    config if created based on the context variables.

  - on BOOT and CONF, changes are applied only if the corresponding context
    variable has changed.

Exception to this are `loc-*-network` scripts, that skip any network configuration after
`INIT`, unless `ETH_RECONFIGURE` is set. The default behaviour is the network
configuration is changed only for new instances, and any subsequent changes are
assumed to be configured manually. `ETH_RECONFIGURE=yes` override this behavior
by applying configuration changes every time teh change is detected. In
these cases network scripts updates only te changed interfaces and only the
relevant configuration settings.

`net-*` scripts will be never run in INIT event, because they are started in
the second run, after network services are completed.


## Download

Latest versions can be downloaded from https://github.com/storpool/one-context-sp


## Install

::

    yum install http://repo.storpoo.com/one-context-sp/centos/7/noarch/Packages/one-context-sp-release-1.0-0.el7.noarch.rpm
    yum install one-context-sp

## Tested platforms

List of tested platforms only:

| Platform                        | Versions                               |
|---------------------------------|----------------------------------------|
| CentOS                          | 7                                      |

(the packages might work on other versions or flavours, but those aren't tested)

## Build own package

### Requirements

* **Linux host**
* **Ruby** >= 1.9
* gem **fpm** >= 1.10.0
* **dpkg utils** for deb package creation
* **rpm utils** for rpm package creation

### Steps

The script `generate.sh` is able to create all package types and can be
configured to include more files in the package or change some of
its parameters. Package type and content are configured by the env. variable
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
reconfiguration, are located in `src/etc/one-context.d/`. Seen note sin the
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
