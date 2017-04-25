## Psql API

A series of functions used for interact directly with `psql` client program or `pg_dump` client program for manage dumps.

### Variables

```eval_rst
  .. list-table::
   :header-rows: 1
   :widths: 10, 20

   * - Variable
     - Description
   * - ``POSTGRESQL_IGNORE_TMZ``
     - This variable is used to avoid set of timezone on session.
   * - ``POSTGRESQL_TMZ``
     - Timezone to use on session. Default is UTC.
   * - ``POSTGRESQL_SHOW_COLUMNS``
     - If this variable is set then columns are visibile on output
       table. Default is hide columns.
   * - ``POSTGRESQL_CLIENT``
     - Path of psql client.
   * - ``POSTGRESQL_FORMAT``
     - Customize format options. Default is unaligned.
   * - ``POSTGRESQL_EXTRA_OPTIONS``
     - Extra options for psql client.
   * - ``POSTGRESQL_CLIENT_DUMP``
     - Path of pg_dump client.
   * - ``POSTGRESQL_USER``
     - Contains Username to use on connection.
   * - ``POSTGRESQL_PWD``
     - Contains password to use on connection.
   * - ``POSTGRESQL_DB``
     - Contains database name to use on connection
   * - ``POSTGRESQL_DIR``
     - Contains path of directory where found project script.

```
### API

#### psql_set_auth_var

Set psql_auth variable with arguments to use with psql client program.
Valorize options like: -u username --password=pwd database.

_Parameters_:

  * `$1`: (db) Name of the schema to use
  * `$2`: (user) User to use on authentication
  * `$3`: (pwd) Password to use on authentication.
  * `$4`: (host) Optionally host of the database server.
  * `$5`: (schema) Optionally schema of the database server.

_Returns_:

  * `0`: always

```eval_rst
.. hidden-literalinclude:: ../../src/core/psql.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: psql_set_auth_var
    :end-before: psql_set_auth_var_end
```

#### psql_cmd_4var

Execute an input statement/command to configured schema.

_Variables Used_:

  * `POSTGRESQL_IGNORE_TMZ`: this variable is used as an alternative to set third parameter
                             of the function and avoid set of timezone on session.
  * `POSTGRESQL_TMZ`: timezone to use on session. Default is UTC.
  * `POSTGRESQL_SHOW_COLUMNS` if this variable is set then columns are visibile on output
                              table. Default is hide columns.
  * `POSTGRESQL_CLIENT`: Path of psql client.
  * `POSTGRESQL_FORMAT`: Customize format options. Default is unaligned.
  * `POSTGRESQL_EXTRA_OPTIONS`: Extra options for psql client.

_Parameters_:

  * `$1`: (var) Name of the variable where is save output command.
  * `$2`: (cmd) Command/statement to execute on configured schema
  * `$3`: (rm_lf) If string length is not zero than from output command are remove LF.
  * `$4`: (avoid_tmz) Flag to avoid set of timezone on session
          (1 to avoid, 0 to leave default). (Optional)

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/psql.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: psql_psql_cmd_4var
    :end-before: psql_psql_cmd_4var_end
```

### Commons Psql API

#### commons_psql_check_client

Check if psql client program is present on system.
If present `POSTGRESQL_CLIENT` variable with abs path is set.
Function check if it is set `psql` variable:
* if it is not set then try to find path through 'which' program
* if it is set then check if path is correct and program exists.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_psql.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_psql_commons_psql_check_client
    :end-before: commons_psql_commons_psql_check_client_end
```

#### commons_psql_check_client_dump

Check if pg_dump client program is present on system.
If present POSTGRESQL_CLIENT_DUMP variable with abs path is set.
Function check if it is set `pg_dump` variable:
* if it is not set then try to find path through 'which' program
* if it is set then check if path is correct and program exists.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_psql.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_psql_commons_psql_check_client_dump
    :end-before: commons_psql_commons_psql_check_client_dump_end
```

#### commons_psql_check_vars

Check if are present mandatary psql environment variables:
 * POSTGRESQL_USER
 * POSTGRESQL_PWD
 * POSTGRESQL_DB
 * POSTGRESQL_DIR

_Returns_:

  * `0`: all mandatory variables are present.
  * `1`: on error (program is interrupter with exit 1 command)

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_psql.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_psql_commons_psql_check_vars
    :end-before: commons_psql_commons_psql_check_vars_end
```

#### commons_psql_check_connection

Check connection to database.

_Returns_:

  * `0`: when connection is ok.
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_psql.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_psql_commons_psql_check_connection
    :end-before: commons_psql_commons_psql_check_connection_end
```

#### commons_psql_shell

Enter on command line shell of Postgresql server.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_psql.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_psql_commons_psql_shell
    :end-before: commons_psql_commons_psql_shell_end
```

#### commons_psql_dump

Dump database or schema from Postgresql server.

_Parameters_:

  * `$1`: (targetfile) File where is stored dump.
  * `$2`: (onlySchema) If equal 1 then dump save only schema without data.
          On default dump save both schema and data. (optional)

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_psql.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_psql_commons_psql_dump
    :end-before: commons_psql_commons_psql_dump_end
```


