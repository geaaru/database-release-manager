## Install Module

Target of this module is manage installation of the projects under `dbrm`.
Currently this module is *not completed and is under heavy development*.

### Commands

#### install version

Show version of install module.

```shell
  $# dbrm install version
  Version: 0.1.0
```
#### install show_installable

Show list of actions to execute on installation between two releases or to a particular release.
Method is currently not completed.

```shell
  $# dbrm install show_installable -h
  [-n name]               Release Name.
  [-t version_to]         Release version target of the installation.
  [-f version_from]       Release version source of the installation.

```

#### install install

Install or upgrade a project to a particular release.
METHOD NOT COMPLETED.

```shell
  $# dbrm install install -h
  [-n name]               Release Name.
  [-t version_to]         Release version target of the installation.
  [-f version_from]       Release version source of the installation.
```

### API

#### _install_check_show_installable_args

Internal function for read and parse command line arguments.

_Command Arguments_:

  * `-n [rel_name]`: Release name. Mandatary argument.
  * `-f [version_from]`: Release version from. Mandatary argument.
  * `-t [version_to]`: Release version to. Mandatary argument.
  * `-h: Show command options

_Variables Used_:

  * `DBM_REL_NAME`: for release name.
  * `DBM_REL_VERSION_TO`: for release version to.
  * `DBM_REL_VERSION_FROM`: for release version from.

_Return_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../modules/install.mod.in
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: install__install_check_show_installable_args
    :end-before: install__install_check_show_installable_args_end
```

