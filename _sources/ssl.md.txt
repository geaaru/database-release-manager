## SSL Module

Target of this module is supply a tool for trace and manage SSL tunnels or
reverse tunnels to reach remote services through SSH channel.

`ssl` module is often used without a dbrm project directory because use default `dbrm`
database under `$HOME/.local/share/dbrm` directory.

### Requirements

`ssl` module when use password for authentication use `sshpass` module that must installed
on host where user enable tunnels.

### Variables

```eval_rst
  .. list-table::
   :header-rows: 1
   :widths: 10, 20

   * - Variable
     - Description
   * - ``DBRM_SSL_ACTIVE_TUN_FILE``
     - Contains path where `ssl` module trace active SSL tunnels and pids.
       Default path is: `$HOME/.local/share/dbrm/dbrm_ssl_tuns`
   * - ``SSHPASS``
     - Variable to define with password when is not used key authentication.
```

### Commands

#### ssl version

Show version of ssl module.

```shell
  $# dbrm ssl version
  Version: 0.1.0
```

#### ssl init

Before use ssl module it is needed execute init command that initialize ssl module
tables inside dbrm database.

This operation is needed only one time.

```shell
  
  $# dbrm ssl init

```

#### ssl deinit

This method remove all defined tunnel and remove `ssl` module tables from active `dbrm` database.

```shell
  
  $# dbrm ssl deinit

```

#### ssl list

Permit to see list of SSL tunnels created on current `dbrm` database.

Last column `PID` is valorized with pid of process that maintain active tunnel.

```shell
  $# dbrm ssl list
  =========================================================================================================
  SSL Tunnels
  =========================================================================================================
  ID    NAME     REMOTE HOST    R PORT  TUNNEL HOST    T HPORT T USER    REVERSE LOCAL PORT  LOCAL HOST PID
  =========================================================================================================
  1     TUNNEL1  172.22.97.120  27017   localhost      20022   root      N       37017                  -
  2     TUNNEL2  192.168.20.10  22      172.16.90.101  22      root      N       20022                  -
```

#### ssl create

Create a SSL tunnel definition. There are two possible types of tunnel: normal tunnel and a reverse tunnel.

A normal tunnel permit to reach a service expose to a remote host in localhost through a specific host.

A reverse tunnel permit to a remote host to reach a particular service to our host or versus a host that is reacheable
from our host.

##### create options:

  * `--on-local-port port`: Local port where binding tcp flow versus remote host
                            through ssl tunnel.
  * `--on-local-host host`: Host (local or an host reachable without tunnel)
                            that will be available in remote host with reverse tunnel.
  * `--remote-host host`: Host to reach through ssl tunnel.
  * `--remote-port port` Port of remote host to reach through ssl tunnel or for
                         reverse tunnel, port in binding to remote host for reach
                         local host.
  * `--tunnel-host host`: Host to use for reach remote host.
  * `--tunnel-hport port: Port of host used for tunnel. Default is 22.
  * `--tunnel-user user: User to use on tunnel creation. Default is current user.
  * `--name name`: Name of the tunnel.
  * `--reverse`: Add this option for reverse tunnel.

* Example of normal tunnel:

```shell
  $# dbrm ssl create --name TUNNEL1 --tunnel-host 172.16.90.101 --tunnel-user root \
     --remote-host 192.168.20.10 --remote-port 22 --on-local-port 20022
```

This command create a normal tunnel with name TUNNEL1 that permit to reach through
local port 20022 SSH port (22) of host 192.168.20.10 thorugh a tunnel with port
SSH of the host 172.16.90.101.
Host 192.168.20.10 is not reachable only from host 172.16.90.101.

* Example of reverse tunnel:

```shell
  $# dbrm ssl create --name TUNNEL2 --tunnel-host 192.168.20.10 --tunnel-user root \
     --remote-host 172.16.90.101 --remote-port 9999 --on-local-port 80 \
     --on-local-host 127.0.0.1 --reverse
```

#### ssl delete

Delete an existing SSL tunnel from `dbrm` database.

##### delete options:

  * `--name name`: Name of the tunnel to delete.
  * `--id-tunnel id`: Id of the tunnel to delete.

```shell
  #$ dbrm ssl delete --name TUNNEL1
  Are you sure to remove tunnel with name TUNNEL1? [yes/no]: yes
```
#### ssl enable

Enable tunnel available on `dbrm` database.

On active tunnel currently process detach SSH process and can't identify if tunnel die.
So, after enable a tunnel it is needed check if is running with `ssl list` command.

##### enable options:

  * `--name name`: Name of the tunnel to activate.
                   Use this or --id-tunnel.
  * `--id-tunnel id: Id of the tunnel to activate.
                     Use this or --name.
  * `--auto-increment`: If local port is busy, automatically
                        increment port until a free port is found.
                        This param is optional.
  * `--no-def-opts`: Disable default options used on tunnel.
                     This param is optional.
  * `--use-sshpass`: Use sshpass for send password to ssh session.
                     For security considerations a best way is to use
                     ssh key authentication.
                     On use sshpass set SSHPASS env variable with
                     password string.

```shell
  $# SSHPASS=pwd dbrm ssl enable --name TUNNEL1 --use-sshpass
  Tunnel 25 is now active with pid 16440.
```

#### ssl disable

Disable an active tunnel.

##### disable options:

  * `--name name`: Name of the tunnel to activate.
                   Use this or --id-tunnel.
  * `--id-tunnel id`: Id of the tunnel to activate.
                      Use this or --name.

```shell
  $# dbrm ssl disable --id-tunnel 1
  Tunnel 1 is not active.
```

