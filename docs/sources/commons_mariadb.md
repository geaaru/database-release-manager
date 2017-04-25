## Commons MariaDB API

A list of functions used with `mysql` client tool to retrieve data from Mysql/MariaDB server.

### API

#### commons_mariadb_check_client

Check if mysql client program is present on system.
If present MARIADB_CLIENT variable with abs path is set.
Function check if it is set `mysql` variable:
* if it is not set then try to find path through 'which' program
* if it is set then check if path is correct and program exists.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mariadb_commons_mariadb_check_client
    :end-before: commons_mariadb_commons_mariadb_check_client_end
```

#### commons_mariadb_check_vars

Check if are present mandatary mariadb environment variables:
 * MARIADB_USER
 * MARIADB_PWD
 * MARIADB_DB
 * MARIADB_DIR

_Returns_:

  * `0`: all mandatory variables are present.
  * `1`: on error (program is interrupter with exit 1 command)

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mariadb_commons_mariadb_check_vars
    :end-before: commons_mariadb_commons_mariadb_check_vars_end
```

#### commons_mariadb_check_connection

Check connection to database.

_Returns_:

  * `0`: when connection is ok.
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mariadb_commons_mariadb_check_connection
    :end-before: commons_mariadb_commons_mariadb_check_connection_end
```

#### commons_mariadb_shell

Enter on command line shell of Mysql/Mariadb server.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mariadb_commons_mariadb_shell
    :end-before: commons_mariadb_commons_mariadb_shell_end
```

#### commons_mariadb_compile_file

Compile file on database.
Output of the compilation is saved on `MYSQL_OUTPUT` variable.

_Parameters_:

  * `$1`: (f) path of the file to compile
  * `$2`: (msg) message to insert on logging file relative to input file

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mariadb_commons_mariadb_compile_file
    :end-before: commons_mariadb_commons_mariadb_compile_file_end
```

