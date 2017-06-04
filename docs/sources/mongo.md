## Mongo Module

A series of functions used for interact directly with `mongo` client program.

### Variables

```eval_rst
  .. list-table::
   :header-rows: 1
   :widths: 10, 20

   * - Variable
     - Description
   * - ``MONGO_CLIENT``
     - Path of mongo client.
   * - ``MONGO_EXTRA_OPTIONS``
     - Extra options for mongo client.
   * - ``MONGO_USER``
     - Contains Username to use on connection.
   * - ``MONGO_PWD``
     - Contains password to use on connection.
   * - ``MONGO_DB``
     - Contains database name to use on connection
   * - ``MONGO_DIR``
     - Contains path of directory where found project script.
   * - ``MONGO_AUTHDB``
     - Contains authentication database to use on connection.
```

### Commands

#### mongo version

Show version of mongo module

```shell
  $# dbrm mongo version
  Version: 0.1.0
```

#### mongo test_connection

Test connection to database of the active profile or active configuration.

##### test_connection options:

This options are generic option for handle connection and are avilable on different
commands.

  * `-P MONGO_PWD`: Override MONGO_PWD variable.
  * `-U MONGO_USER`: Override MONGO_USER with username of the connection.
  * `-H MONGO_HOST`: Override MONGO_HOST with host of the database.
  * `-D MONGO_DIR`: Override MONGO_DIR directory where save/retrieve script/functions, etc.
  * `--database db`: Override MONGO_DB variable for database name.
  * `--conn-options opts`: Override MONGO_EXTRA_OPTIONS variable for enable extra
                           connection options.
  * `--authdb db`: Override MONGO_AUTHDB variable for set authentication database.

#### mongo shell

Enter on mongo shell of the active profile or active configuration.

##### shell options:

  * `-P MONGO_PWD`: Override MONGO_PWD variable.
  * `-U MONGO_USER`: Override MONGO_USER with username of the connection.
  * `-H MONGO_HOST`: Override MONGO_HOST with host of the database.
  * `-D MONGO_DIR`: Override MONGO_DIR directory where save/retrieve script/functions, etc.
  * `--database db`: Override MONGO_DB variable for database name.
  * `--conn-options opts`: Override MONGO_EXTRA_OPTIONS variable for enable extra
                           connection options.
  * `--authdb db`: Override MONGO_AUTHDB variable for set authentication database.


### API

#### mongo_set_auth_var

Set mongo_auth variable with arguments to use with mongo client program.
Valorize options like: -u username --password=pwd database.

_Parameters_:

  * `$1`: (db) Name of the schema to use
  * `$2`: (user) User to use on authentication
  * `$3`: (pwd) Password to use on authentication.
  * `$4`: (host) Optionally host of the database server.
  * `$5`: (auth_db) Optionally authentication database to use on authentication.

_Returns_:

  * `0`: always

```eval_rst
.. hidden-literalinclude:: ../../src/core/mongo.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: mongo_set_auth_var
    :end-before: mongo_set_auth_var_end
```

### Commons Mongo API

#### commons_mongo_check_client

Check if mongo client program is present on system.
If present `MONGO_CLIENT` variable with abs path is set.
Function check if it is set `mongo` variable:
* if it is not set then try to find path through 'which' program
* if it is set then check if path is correct and program exists.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mongo.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mongo_commons_mongo_check_client
    :end-before: commons_mongo_commons_mongo_check_client_end
```

#### commons_mongo_check_vars

Check if are present mandatary mongo environment variables:
 * MONGO_USER
 * MONGO_PWD
 * MONGO_DB
 * MONGO_DIR

_Returns_:

  * `0`: all mandatory variables are present.
  * `1`: on error (program is interrupter with exit 1 command)

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mongo.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mongo_commons_mongo_check_vars
    :end-before: commons_mongo_commons_mongo_check_vars_end
```

#### commons_mongo_check_connection

Check connection to database.

_Returns_:

  * `0`: when connection is ok.
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mongo.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mongo_commons_mongo_check_connection
    :end-before: commons_mongo_commons_mongo_check_connection_end
```

#### commons_mongo_shell

Enter on command line shell of MongoDB server.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mongo.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mongo_commons_mongo_shell
    :end-before: commons_mongo_commons_mongo_shell_end
```

