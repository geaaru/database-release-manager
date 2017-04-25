## Sqlplus API

A series of functions used for interact directly with `sqlplus` client program.

### API

#### sqlplus_set_sqlplus_auth_var

Set sqlplus_auth variable with authentication string like: USER/PASSWD@TNSNAME.

_Parameters_:

  * `$1`: (db) Name of the schema to use
  * `$2`: (user) User to use on authentication
  * `$3`: (pwd) Password to use on authentication.

_Returns_:

  * `0`: always

```eval_rst
.. hidden-literalinclude:: ../../src/core/sqlplus.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: sqlplus_set_sqlplus_auth_var
    :end-before: sqlplus_set_sqlplus_auth_var_end
```

#### sqlplus_file

Compile a file and save output to input variable.

_Parameters_:

  * `$1`: (var) Name of the variable where is save output command.
  * `$2`: (f) File to compile.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/sqlplus.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: sqlplus_sqlplus_file
    :end-before: sqlplus_sqlplus_file_end
```
#### sqlplus_cmd_4var

Execute an input statement/command to configured schema.

_Parameters_:

  * `$1`: (var) Name of the variable where is save output command.
  * `$2`: (cmd) Command/statement to execute on configured schema
  * `$3`: (rm_lf) If string length is not zero than from output command are remove LF.
  * `$4`: (feedback) Set feedback option value.
          If equal to empty string default value is "off".

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/sqlplus.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: sqlplus_sqlplus_cmd_4var
    :end-before: sqlplus_sqlplus_cmd_4var_end
```

