# OpenNebula Contextualization Scripts

Copyright (C) 2019 StorPool

This package provides a replacement package for one-context by OpenNebula.
More information about the replaced package (by OpenNebula) can be found here:
https://github.com/OpenNebula/addon-context-linux

This replacement resolves the number of issues with the original
contextualization package. The main problem with the original package is that
change in one parameter causes all configuration setting to be reset.  Some
parts were rewritten from scratch, others have small or no modifications from
the original package.

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


## Event types

### `INIT`

This is the first boot after the instance is created. It is detected by changed
value of `INSTANCE_ID`, that shall be the VM ID in OpenNebula. To generate
correct `INSTANCE_ID` add to the template's CONTEXT the following custom
variable:

```
INSTANCE_ID = "$VMID"
```

If `INSTANCE_ID` is not present, a fallback method based on the MAC address of
the first Ethernet interfaces is used to detect a new instance is created.

On `INIT` event each script will typically rebuild clean configuration based
only on the CONTEXT variable, ignoring (and deleting) any existing
configuration. Behavior of some scripts may differ - see sections below.

### `BOOT`

This event is every boot after the `INIT`. `BOOT` Event is currently detected
by inspecting `uptime`, but this implementation may change in the future. If
`one-contexd` is invoked when uptime is less then 120 seconds, it assumes this
is a `BOOT` event.

On `BOOT` scripts will behave like on `CONF` event. There could be exceptions.

### `CONF`

This events is when CONTEXT change has been detected. It is triggered by
ejecting and inserting a CONTEXT CD. Some hardware changes, like attach network
interface or resize of a disk can also trigger `CONF` event.

On `CONF` event scripts are executed only if the `context.sh` file in the CONTEXT CD
has been changed or `one-contextd` was called with `force` parameter (on
hardware change).

On `CONF` event, each script depending on its function will either ignore any
changes or update the configuration, but only if the corresponding CONTEXT
variables are changed. This behavior is script specific. See the sections below.


## Special CONTEXT variables:

### `loc-10-network`

By default, `loc-10-network` script will (re-)configure network setting only on
instantiation (`INIT`) - i.e. first boot after the VM is cloned from the
template. Any subsequent execution will just ignore changes in the CONTEXT
variables and will not make any changes to the running configuration. This is
true for exiting interfaces as well as for newly attached network interfaces -
i.e. new interfaces will not be configured and activated automatically, IP
aliases will not be added or deleted.

#### `ETH_RECONFIGURE`

To enable re-configuration of network interfaces after `INIT` stage, set
CONTEXT variable `ETH_RECONFIGURE=yes`. This will make the script to apply
CONTEXT changes to the network configuration, including adding and deleting
interfaces and IP aliases.

Set `ETH_RECONFIGURE=yes` if you want OpenNebula to manage / configure IP
interfaces in the VM. Delete `ETH_RECONFIGURE`, set it to `no` or blank if you
manage the IP configuration in the VM by some other means.

`ETH_RECONFIGURE` has no effect on `INIT` event. This will usually allow the
first interface to be initialized by OpenNebula, allowing remote access to the
VM.

#### `ETH<x>_NOALIAS`

If `ETH<x>_NOALIAS` is non-blank, context scripts will not add IP aliases to
this interface only. However if there is already a configuration file
`ifcfg-eth<x>:<y>` and IP alias `<y>` is deleted from OpenNebula, the context
script will delete IP alias and the configuration file as well.

### `loc-11-dns`

Like `loc-10-network`, this script by default applies changes only on `INIT`
events. To change this use `ETH_RECONFIGURE`.

### `loc-20-set-username-password`

On `INIT`, this script will create user defined in `USERNAME` CONTEXT variable
if it does not exists. If `USERNAME` is not defined it will use `root`.

On `INIT` if any of the CONTEXT variables `PASSWORD`,
`CRYPTED_PASSWORD_BASE64`, `CRYPTED_PASSWORD`, `PASSWORD_BASE64`, `PASSWORD`
are set, the script will change the password of `USERNAME` user (or `root`).

On `BOOT` and `CONF` events, the script will update the password only if any of
the variables above has been changed`.

#### `PASSWORD_SERIAL`

Changes of the `PASSWORD_SERIAL` variable, causes the password to be reset,
even if none of the `PASSWORD*` variables was changed. This can be used to
reset the password to the same value as before.  Good practice is to set
`PASSWORD_SERIAL` to current unix timestamp or use a large random value.


## Installation

When this package is installed for the first time or when it replaces the
original OpenNebula package, this is detected by the package as `CONF` event.
This is intentional and will prevent all co settings to be reinitialized on the
existing deployments.

## Force `INIT` on existing deployments

If you want to force `INIT` event on exsitnig deployment e.g. to reset all
current configuration or for troubleshooting, set
`/var/lib/one-context/INSTANCE_ID` to some random value and reboot the VM.


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
