
## Logfile Module

Target of this module is supply logging features to user and to dbrm itself.

### Variables

```eval_rst
  .. list-table::
   :header-rows: 1
   :widths: 10, 20

   * - Variable
     - Description
   * - ``LOGFILE``
     - Contains path of logfile to use. If this variable is not set call to write command do nothing.

```

### Commands

#### logfile version

Show version of logfile module.

```bash
  $# dbrm logfile version 
  Version: 0.1.0
```

#### logfile info

With info command is possible retrieve status of the `logfile` module and what is current logfile use for store logging string.

```bash

  $# dbrm logfile info
  ===========================================================================
  Module [logfile]:
  ---------------------------------------------------------------------------
  Logfile = ./dbm.log
  Status  = 1
  ---------------------------------------------------------------------------
  ===========================================================================

```

#### logfile reset

Remove current logfile.

_Exit Values_:

  * `1`: On error or if logfile module is not enabled.
  * `0`: On success

``` bash

  $# dbrm logfile reset
  Are you sure to remove file ./dbm.log ? [y/N]y
  File ./dbm.log removed correctly.

```

#### logfile write

This command permit from a shell logging message to configured logfile. Every message contains a date and a line as seperator.

_Exit Values_:

  * `1`: On error
  * `0`: On success

``` bash

  $# dbrm logfile write "INFO - Test logging"
  $# cat ./dbm.log
  ------------------------------------------------------
  20170422-18:58:34 - INFO - Test logging
  ------------------------------------------------------

```

### API

#### _logfile_init

Method called when module logfile is initialized.
Check if it is defined LOGFILE variable and check if file is writable.
If LOGFILE variable is not set then logfile module is automatically disabled.

```eval_rst
.. hidden-literalinclude:: ../../modules/logfile.mod.in
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: logfile__logfile_init
    :end-before: logfile__logfile_init_end
```

#### _logfile_write

Internal function that write input message to logfile.

_Parameters_:

  * `$1`:  message to write on logfile

_Returns_:

  * `1`: On error
  * `0`: On success

``` bash
   # Write message to logfile
   _logfile_write "My message to write on LOGFILE!!!"
```

```eval_rst
.. hidden-literalinclude:: ../../modules/logfile.mod.in
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: logfile__logfile_write
    :end-before: logfile__logfile_write_end
```

