## Mysql API

A series of functions used for interact directly with `mysql` (for both Mysql or MariaDB servers) client program.

### Variables

```eval_rst
  .. list-table::
   :header-rows: 1
   :widths: 10, 20

   * - Variable
     - Description
   * - ``MARIADB_IGNORE_TMZ``
     - This variable is used as an alternative to set third parameter
       of the function and avoid set of timezone on session.
   * - ``MARIADB_TMZ``
     - Set timezone to use on session. Default is UTC.
   * - ``MARIADB_SHOW_COLUMNS``
     - If this variable is set remove '-N' option from mysql client
       command to print column data.
   * - ``MARIADB_CLIENT``
     - Path of mysql client.
   * - ``MARIADB_EXTRA_OPTIONS``
     - Extra options for mysql client.
   * - ``MARIADB_DB``
     - Name of the schema/database to use.
   * - ``MARIADB_ENABLE_COMMENTS``
     - With value 0 (disable) or 1 (enable) insert of comments
       in compilation. Default is 0.
   * - ``MARIADB_IGNORE_TMZ``
     - If set to 1 then *dbrm* avoid to set timezone on session.
   * - ``MYSQL5_6_ENV_PWD``
     - From version 5.6 of mysql command line command is present an annoying warning
       message like this 'Warning: Using a password on the command line interface
       can be insecure.' when is used a --password argument.
       This warning message broken database-release-manager and it is required add
       MYSQL5_6_ENV_PWD="1" on dbrm.conf file.
```
### API

#### mysql_set_auth_var

Set `mysql_auth` variable with authentication string like: -u username --password=pwd database to use with mysql client program.

_Parameters_:

  * `$1`: (db) Name of the schema to use.
  * `$2`: (user) User to use on authentication
  * `$3`: (pwd) Password to use on authentication
  * `$4`: (host) Optionally host of the database server.

_Returns_:

  * `0`: always

```eval_rst
.. hidden-literalinclude:: ../../src/core/mysql.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: mysql_mysql_set_auth_var
    :end-before: mysql_mysql_set_auth_var_end
```
TODO:
  * add support to configuration file with credentials.

#### mysql_file

Compile a file and save output to input variable.

_Notes_:

This command try to repalce string \`DB_NAME\` with name of the schema
defined on MARIADB_DB variable.

_Variables Used_:
  * `MARIADB_IGNORE_TMZ`: this variable is used as an alternative to set third parameter
                          of the function and avoid set of timezone on session.
  * `MARIADB_TMZ`: timezone to use on session. Default is UTC.
  * `MARIADB_SHOW_COLUMNS` if this variable is set remove '-N' option from mysql client
                           command to print column data.
  * `MARIADB_CLIENT`: Path of mysql client.
  * `MARIADB_EXTRA_OPTIONS`: Extra options for mysql client.
  * `MARIADB_DB`: name of the schema to use.
  * `MARIADB_ENABLE_COMMENTS`: With value 0 (disable) or 1 (enable) insert of comments
                               in compilation. Default is 0.

_Parameters_:

  * `$1`: Name of the variable where is save output command.
  * `$2`: File to compile.
  * `$3`: Flag to avoid set of timezone on session (1 to avoid, 0 to leave default).
          (Optional)

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/mysql.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: mysql_mysql_file
    :end-before: mysql_mysql_file_end
```

#### mysql_source_file

Compile a file and save output to input variable.
This command is an alternative to mysql_file function that use source command.
This command doesn't replace placeholder DB_NAME.

_Variables Used_:
  * `MARIADB_IGNORE_TMZ`: this variable is used as an alternative to set third parameter
                          of the function and avoid set of timezone on session.
  * `MARIADB_TMZ`: timezone to use on session. Default is UTC.
  * `MARIADB_SHOW_COLUMNS` if this variable is set remove '-N' option from mysql client
                           command to print column data.
  * `MARIADB_CLIENT`: Path of mysql client.
  * `MARIADB_EXTRA_OPTIONS`: Extra options for mysql client.
  * `MARIADB_DB`: name of the schema to use.
  * `MARIADB_ENABLE_COMMENTS`: With value 0 (disable) or 1 (enable) insert of comments
                               in compilation. Default is 0.

_Parameters_:

  * `$1`: Name of the variable where is save output command.
  * `$2`: File to compile.
  * `$3`: Flag to avoid set of timezone on session (1 to avoid, 0 to leave default).
          (Optional)

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/mysql.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: mysql_mysql_source_file
    :end-before: mysql_mysql_source_file_end
```

#### mysql_cmd_4var

Execute an input statement on configured schema.

_Variables Used_:
  * `MARIADB_IGNORE_TMZ`: this variable is used as an alternative to set third parameter
                          of the function and avoid set of timezone on session.
  * `MARIADB_TMZ`: timezone to use on session. Default is UTC.
  * `MARIADB_SHOW_COLUMNS` if this variable is set remove '-N' option from mysql client
                           command to print column data.
  * `MARIADB_CLIENT`: Path of mysql client.
  * `MARIADB_EXTRA_OPTIONS`: Extra options for mysql client.
  * `MARIADB_DB`: name of the schema to use.
  * `MARIADB_ENABLE_COMMENTS`: With value 0 (disable) or 1 (enable) insert of comments
                               in compilation. Default is 0.

_Parameters_:

  * `$1`: (var) Name of the variable where is save output command.
  * `$2`: (cmd) Command to execute.
  * `$3`: (rm_lf) If string length is not zero than from output command are remove LF.
  * `$4`: (avoid_tmz) Flag to avoid set of timezone on session (1 to avoid, 0 to leave default).
          (Optional)

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/mysql.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: mysql_mysql_cmd_4var
    :end-before: mysql_mysql_cmd_4var_end
```

