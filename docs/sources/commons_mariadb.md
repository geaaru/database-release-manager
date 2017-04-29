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

#### commons_mariadb_source_file

Compile file on database (with source command).
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
    :start-after: commons_mariadb_commons_mariadb_source_file
    :end-before: commons_mariadb_commons_mariadb_source_file_end
```

#### commons_mariadb_compile_fkey

Compile file related with foreign key on database.
Output of the compilation is saved on `MYSQL_OUTPUT` variable.

_Parameters_:

  * `$1`: (f) path of the file to compile
  * `$2`: (msg) message to insert on logging file relative to input file
  * `$3`: (force) If foreign key is present and force argument is equal to 1,
          then foreign key is dropped and added again.
  * `$4`: (fk_table) table of the foreign key

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mariadb_commons_mariadb_compile_fkey
    :end-before: commons_mariadb_commons_mariadb_compile_fkey_end
```

#### commons_mariadb_compile_idx

Compile file related with index of a table to database.
Output of the compilation is saved on `MYSQL_OUTPUT` variable.

_Parameters_:

  * `$1`: (f) path of the file to compile
  * `$2`: (msg) message to insert on logging file relative to input file
  * `$3`: (force) if index is present and force is equal to 1, then
          index is dropped and added again.
  * `$4`: (idx_table) table of the index

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mariadb_commons_mariadb_compile_idx
    :end-before: commons_mariadb_commons_mariadb_compile_idx_end
```

#### commons_mariadb_compile_all_procedures

Compile all files under MARIADB_DIR/procedures directory.

_Parameters_:

  * `$1`: (msg) message to insert on logging file relative to input file.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mariadb_commons_mariadb_compile_all_procedures
    :end-before: commons_mariadb_commons_mariadb_compile_all_procedures_end
```

#### commons_mariadb_compile_all_triggers

Compile all files under MARIADB_DIR/triggers directory.

_Parameters_:

  * `$1`: (msg) message to insert on logging file relative to input file.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mariadb_commons_mariadb_compile_all_triggers
    :end-before: commons_mariadb_commons_mariadb_compile_all_triggers_end
```

#### commons_mariadb_compile_all_functions

Compile all files under MARIADB_DIR/functions directory.

_Parameters_:

  * `$1`: (msg) message to insert on logging file relative to input file.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mariadb_commons_mariadb_compile_all_functions
    :end-before: commons_mariadb_commons_mariadb_compile_all_functions_end
```

#### commons_mariadb_compile_all_views

Compile all files under MARIADB_DIR/views directory.

_Parameters_:

  * `$1`: (msg) message to insert on logging file relative to input file.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mariadb_commons_mariadb_compile_all_views
    :end-before: commons_mariadb_commons_mariadb_compile_all_views_end
```

#### commons_mariadb_compile_all_fkeys

Compile all files under MARIADB_DIR/foreign_keys directory.

_Parameters_:

  * `$1`: (msg) message to insert on logging file relative to input file.
  * `$2`: (force) if equals to 1, force compilation of all foreign keys also
          if already present.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mariadb_commons_mariadb_compile_all_fkeys
    :end-before: commons_mariadb_commons_mariadb_compile_all_fkeys_end
```

#### commons_mariadb_compile_all_idxs

Compile all files under MARIADB_DIR/indexes directory.

_Parameters_:

  * `$1`: (msg) message to insert on logging file relative to input file.
  * `$2`: (force) if equals to 1, force compilation of all indexes also
          if already present.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mariadb_commons_mariadb_compile_all_idxs
    :end-before: commons_mariadb_commons_mariadb_compile_all_idxs_end
```
#### commons_mariadb_compile_all_events

Compile all files under MARIADB_DIR/events directory.

_Parameters_:

  * `$1`: (msg) message to insert on logging file relative to input file.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mariadb_commons_mariadb_compile_all_events
    :end-before: commons_mariadb_commons_mariadb_compile_all_events_end
```

#### commons_mariadb_compile_all_from_dir

Compile all files from input directory with .sql extension.

_Parameters_:

  * `$1`: (directory) Directory where there are files to compile.
  * `$2`: (msg_head) Title message insert on logfile before compile files.
  * `$3`: (msg) message insert on logfile before compile files.
  * `$4`: (type) Identify type of directory: fkey|procedure|function|view.
          Optional.
  * `$5`: (closure) custom parameter with a value relative to type.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mariadb_commons_mariadb_compile_all_from_dir
    :end-before: commons_mariadb_commons_mariadb_compile_all_from_dir_end
```

#### commons_mariadb_count_fkeys

Count number of foreign keys present on database.

_Parameters_:

  * `$1`: (tname) table name to use on count foreign keys. Optional.
  * `$2`: (mode) if tname is present this field could be used for identify
          if count must be done for foreign key of the table or
          foreign keys that reference table.
          Optional field.
          Possible values are: "in" (default) | "ref"

_Returns_:

  Number of foreign keys found.

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mariadb_commons_mariadb_count_fkeys
    :end-before: commons_mariadb_commons_mariadb_count_fkeys_end
```

#### commons_mariadb_count_procedures

Count number of procedures present on database.

_Returns_:

  Number of procedures found.

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mariadb_commons_mariadb_count_procedures
    :end-before: commons_mariadb_commons_mariadb_count_procedures_end
```

#### commons_mariadb_count_functions

Count number of functions present on schema.

_Returns_:

  Number of functions found on schema.

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mariadb_commons_mariadb_count_functions
    :end-before: commons_mariadb_commons_mariadb_count_functions_end
```

#### commons_mariadb_count_triggers

Count number of triggers defined on schema.

_Returns_:

  Number of triggers found on schema.

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mariadb_commons_mariadb_count_triggers
    :end-before: commons_mariadb_commons_mariadb_count_triggers_end
```

#### commons_mariadb_count_views

Count number of views present on schema.

_Returns_:

  Number of views available on schema.

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mariadb_commons_mariadb_count_views
    :end-before: commons_mariadb_commons_mariadb_count_views_end
```

#### commons_mariadb_count_events

Count number of events present on schema.

_Returns_:

  Number of events available on schema.

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mariadb_commons_mariadb_count_events
    :end-before: commons_mariadb_commons_mariadb_count_events_end
```

#### commons_mariadb_count_indexes

Count number of indexes present on database.

_Parameters_:

  * `$1`: (tname) Argument $1 if isn't an empty string identify table name.
  * `$2`: (idx_types) Argument $2 identify indexes types.
          Values are: "all" (default), "primary", "not_primary"

_Returns_:

  Number of indexes found.

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mariadb_commons_mariadb_count_indexes
    :end-before: commons_mariadb_commons_mariadb_count_indexes_end
```

#### commons_mariadb_check_if_exist_procedure

Check if exists procedure with name in input on schema.

_Returns_:

  * `0`: if exists.
  * `1`: if not exists

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_check_if_exist_procedure
    :end-before: commmons_mariadb_commons_mariadb_check_if_exist_procedure_end
```

#### commons_mariadb_check_if_exist_function

Check if exists function with name in input on schema.

_Returns_:

  * `0`: if exists.
  * `1`: if not exists

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_check_if_exist_function
    :end-before: commmons_mariadb_commons_mariadb_check_if_exist_function_end
```

#### commons_mariadb_check_if_exist_view

Check if exists view with name in input on schema.

_Returns_:

  * `0`: if exists.
  * `1`: if not exists

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_check_if_exist_view
    :end-before: commmons_mariadb_commons_mariadb_check_if_exist_view_end
```

#### commons_mariadb_check_if_exist_fkey

Check if exists foreign keys with name in input on schema.

_Returns_:

  * `0`: if exists.
  * `1`: if not exists
  * `2`: if argument tname is not present this means that there are
         two foreign key with same name.

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_check_if_exist_fkey
    :end-before: commmons_mariadb_commons_mariadb_check_if_exist_fkey_end
```

#### commons_mariadb_check_if_exist_index

Check if exists index with name and table name in input on schema.

_Parameters_:

  * `$1`: (index_name) Identify index name.
  * `$2`: (table_name) Identify table name of the index.

_Returns_:

  * `0`: if exists.
  * `1`: if not exists

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_check_if_exist_index
    :end-before: commmons_mariadb_commons_mariadb_check_if_exist_index_end
```

#### commons_mariadb_get_triggers_list

Save on `_mariadb_ans` variable list of triggers defined on schema.

_Returns_:

  * `0`: on success.
  * `1`: on error.

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_get_triggers_list
    :end-before: commmons_mariadb_commons_mariadb_get_triggers_list_end
```

#### commons_mariadb_count_tables

Count tables of the schema.

_Returns_:

  Number of tables found.

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_count_tables
    :end-before: commmons_mariadb_commons_mariadb_count_tables_end
```

#### commons_mariadb_get_fkeys_list

Save on `_mariadb_ans` variable list of foreign keys defined on schema.

_Parameters_:

  * `$1`: (all) If valorized then list contains columns CONSTRAINT_NAME,
          TABLE_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME,
          REFERENCED_COLUMN_NAME, UPDATE_RULE, DELETE_RULE
  * `$2`: (custom_column) If all paramaeter is empty through this parameter
          is possible define columns to return.
  * `$3`: (fkey_name) Foreign key name to filter. Optional.
  * `$4`: (tname) Table name to use on filter. Optional
  * `$5`: (mode) if tname is present this field could be used for identify
          count must be done for count foreign key of the table or foreign
          keys that reference table. Optional parameter.
          Possible values are: "in" (default) | "ref"

_Returns_:

  * `0`: on success.
  * `1`: on error.

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_get_fkeys_list
    :end-before: commmons_mariadb_commons_mariadb_get_fkeys_list_end
```

#### commons_mariadb_get_indexes_list

Save on `_mariadb_ans` variable list of indexes defined on schema.

_Parameters_:

  * `$1`: (idx_types) Identify indexes types.
          Values are: "all" (default), "primary", "not_primary"
  * `$2`: (custom_column) If not empty defined list of column returned.
  * `$3`: (tname) Table name to use on filter. Optional
  * `$4`: (index_name) Index name to filter. Optional.

_Returns_:

  * `0`: on success.
  * `1`: on error.

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_get_indexes_list
    :end-before: commmons_mariadb_commons_mariadb_get_indexes_list_end
```

#### commons_mariadb_get_tables_list

Save on `_mariadb_ans` variable list of tables defined on schema.

_Parameters_:

  * `$1`: (all) If valorized then list contains columns TABLE_NAME,
          ENGINE, TABLE_ROWS, DATA_LENGTH, CHARACTER_SET_NAME, CREATE_TIME,
          UPDATE_TIME
  * `$2`: (custom_column) If all paramaeter is empty through this parameter
          is possible define columns to return.
  * `$3`: (tname) Table name to use on filter. Optional

_Returns_:

  * `0`: on success.
  * `1`: on error.

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_get_tables_list
    :end-before: commmons_mariadb_commons_mariadb_get_tables_list_end
```

#### commons_mariadb_desc_table

Save on `_mariadb_ans` variable list of columns of input table.

_Parameters_:

  * `$1`: (tname) Table name to use on filter.
  * `$2`: (custom_column) If all paramaeter is empty through this parameter
          is possible define columns to return.
  * `$3`: (cname) Permit to filter for column name if not empty.

_Returns_:

  * `0`: on success.
  * `1`: on error.

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_desc_table
    :end-before: commmons_mariadb_commons_mariadb_desc_table_end
```

#### commons_mariadb_exist_table

Check if exists table in input.

_Parameters_:

  * `$1`: (tname) Table name to search.

_Returns_:

  * `0`: if table exists.
  * `1`: on error or if table is not exists.

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_exist_table
    :end-before: commmons_mariadb_commons_mariadb_exist_table_end
```

#### commons_mariadb_exist_event

Check if exists event in input.

_Parameters_:

  * `$1`: (ename) Event name to search.

_Returns_:

  * `0`: if table exists.
  * `1`: on error or if table is not exists.

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_exist_event
    :end-before: commmons_mariadb_commons_mariadb_exist_event_end
```

#### commons_mariadb_get_procedures_list

Save on `_mariadb_ans` variable list of procedures defined on schema.

_Parameters_:

  * `$1`: (all) If valorized then are returned columsn ROUTINE_NAME,
                DEFINER, CREATED, LAST_ALTERED otherwize only
                ROUTINE_NAME.

_Returns_:

  * `0`: on success.
  * `1`: on error.

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_get_procedures_list
    :end-before: commmons_mariadb_commons_mariadb_get_procedures_list_end
```

#### commons_mariadb_get_functions_list

Save on `_mariadb_ans` variable list of functions defined on schema.

_Parameters_:

  * `$1`: (all) If valorized then are returned columsn ROUTINE_NAME,
                DEFINER, CREATED, LAST_ALTERED otherwize only
                ROUTINE_NAME.

_Returns_:

  * `0`: on success.
  * `1`: on error.

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_get_functions_list
    :end-before: commmons_mariadb_commons_mariadb_get_functions_list_end
```

#### commons_mariadb_get_events_list

Save on `_mariadb_ans` variable list of events defined on schema.
Data are returned as a row with pipe (|) separator.

_Parameters_:

  * `$1`: (opt) If equal to 'all' then are returned columns EVENT_NAME,
                DEFINER, TIME_ZONE, EVENT_TYPE, EXECUTE_AT, INTERVAL_VALUE,
                INTERVAL_FIELD, STARTS , ENDS, STATUS, ON_COMPLETION,
                CREATED, LAST_ALTERED, LAST_EXECUTED, EVENT_COMMENT
                otherwise EVENT_NAME, DEFINED, TIME_ZONE, EVENT_TYPE,
                STATUS, CREATED end LAST_EXECUTED.
  * `$`: (ename) Name of the event.

_Returns_:

  * `0`: on success.
  * `1`: on error.

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_get_events_list
    :end-before: commmons_mariadb_commons_mariadb_get_events_list_end
```

#### commons_mariadb_get_views_list

Save on `_mariadb_ans` variable list of views defined on schema.

_Returns_:

  * `0`: on success.
  * `1`: on error.

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_get_views_list
    :end-before: commmons_mariadb_commons_mariadb_get_views_list_end
```

#### commons_mariadb_check_if_exist_trigger

Check if exists a trigger with name in input on schema.

_Parameters_:

  * `$1`: (name) Name of the trigger to search
  * `$2`: (tname) Name of the table of the trigger to search.
          Optional paramenter.

_Returns_:

  * `0`: if exists
  * `1`: if not exists

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_check_if_exist_trigger
    :end-before: commmons_mariadb_commons_mariadb_check_if_exist_trigger_end
```

#### commons_mariadb_download_procedure

Download a procedure to MARIADB_DIR/procedures directory.

_Parameters_:

  * `$1`: (name) Name of the procedure.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_download_procedure
    :end-before: commmons_mariadb_commons_mariadb_download_procedure_end
```

#### commons_mariadb_download_function

Download a function to MARIADB_DIR/functions directory.

_Parameters_:

  * `$1`: (name) Name of the function.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_download_function
    :end-before: commmons_mariadb_commons_mariadb_download_function_end
```

#### commons_mariadb_download_trigger

Download a trigger to MARIADB_DIR/triggers directory.

_Parameters_:

  * `$1`: (name) Name of the trigger to download.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_download_trigger
    :end-before: commmons_mariadb_commons_mariadb_download_trigger_end
```

#### commons_mariadb_download_event

Download an event to MARIADB_DIR/events directory.

_Parameters_:

  * `$1`: (name) Name of the event to download.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_download_event
    :end-before: commmons_mariadb_commons_mariadb_download_event_end
```

#### commons_mariadb_download_view

Download a view to MARIADB_DIR/views directory.

_Parameters_:

  * `$1`: (name) Name of the view to download.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_download_view
    :end-before: commmons_mariadb_commons_mariadb_download_view_end
```

#### commons_mariadb_download_all_views

Download all views to MARIADB_DIR/views directory.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_download_all_views
    :end-before: commmons_mariadb_commons_mariadb_download_all_views_end
```

#### commons_mariadb_download_all_procedures

Download all procedures to MARIADB_DIR/procedures directory.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_download_all_procedures
    :end-before: commmons_mariadb_commons_mariadb_download_all_procedures_end
```

#### commons_mariadb_download_all_functions

Download all functions to MARIADB_DIR/functions directory.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_download_all_functions
    :end-before: commmons_mariadb_commons_mariadb_download_all_functions_end
```

#### commons_mariadb_download_all_triggers

Download all triggers to MARIADB_DIR/triggers directory.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_download_all_triggers
    :end-before: commmons_mariadb_commons_mariadb_download_all_triggers_end
```

#### commons_mariadb_download_all_events

Download all events to MARIADB_DIR/schedulers directory.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_download_all_events
    :end-before: commmons_mariadb_commons_mariadb_download_all_events_end
```

#### commons_mariadb_download_fkey

Download a foreign key to MARIADB_DIR/foreign_keys directory.

_Parameters_:

  * `$1`: (name) name of the foreign key to download.
  * `$2`: (tname) table name related with foreign key to download.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_download_fkey
    :end-before: commmons_mariadb_commons_mariadb_download_fkey_end
```

#### commons_mariadb_download_all_fkeys

Download all foreign keys to MARIADB_DIR/foreign_keys directory.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_download_all_fkeys
    :end-before: commmons_mariadb_commons_mariadb_download_all_fkeys_end
```

#### commons_mariadb_drop_fkey

Drop a foreign key from database if exists.

_Parameters_:

  * `$1`: (fkey) name of the foreign key to drop.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_drop_fkey
    :end-before: commmons_mariadb_commons_mariadb_drop_fkey_end
```

#### commons_mariadb_download_index

Download a index key (primary, unique, spatial) to MARIADB_DIR/indexes directory.

_Parameters_:

  * `$1`: (name) name of the index key to download.
  * `$2`: (tname) table name related with index to download.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_download_index
    :end-before: commmons_mariadb_commons_mariadb_download_index_end
```

#### commons_mariadb_download_all_indexes

Download all indexes to MARIADB_DIR/indexes directory.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_download_all_indexes
    :end-before: commmons_mariadb_commons_mariadb_download_all_indexes_end
```

#### commons_mariadb_drop_index

Drop a index from database if exists.

_Parameters_:

  * `$1`: (fkey) name of the index key to drop.
  * `$2`: (tname) Name of the table related with the index to drop.
  * `$3`: (avoid_warn) If not empty and index doesn't exist no warning
          message are printed.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_drop_index
    :end-before: commmons_mariadb_commons_mariadb_drop_index_end
```

#### commons_mariadb_create_fkey_file

Create foreign key file for compilation.

_Parameters_:

  * `$1`: (name) name of the foreign key to create
  * `$2`: (table) Name of the table where create foreign key
  * `$3`: (cname) list of columns related with foreign key.
  * `$4`: (rtable) name of the table reference
  * `$5`: (rcname) list of the columns reference on foreign key.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_create_fkey_file
    :end-before: commmons_mariadb_commons_mariadb_create_fkey_file_end
```

#### commons_mariadb_create_fkey_file

Create index file for compilation.

_Parameters_:

  * `$1`: (name) name of the index to create
  * `$2`: (table) name of the table where create index.
  * `$3`: (keys) list of columns of the index.
  * `$4`: (itable) for particolar index could be contains
          "UNIQUE" | "FULLTEXT" | "SPATIAL"

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_create_index_file
    :end-before: commmons_mariadb_commons_mariadb_create_index_file_end
```

#### commons_mariadb_get_table_def

Create table definition syntax and store it on TABLE_DEF variable.

_Parameters_:

  * `$1`: (name) name of the table

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_get_table_def
    :end-before: commmons_mariadb_commons_mariadb_get_table_def_end
```

#### commons_mariadb_download_all_tables

Extract all tables definition and write its to a target file.

_Parameters_:

  * `$1`: (f) file name path where save tables schema.
  * `$2`: (tname) download only schema of a particular table.
          Optional parameter.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_download_all_tables
    :end-before: commmons_mariadb_commons_mariadb_download_all_tables_end
```

#### commons_mariadb_drop_trigger

Drop a trigger from database if exists.

_Parameters_:

  * `$1`: (fkey) name of the trigger to drop.
  * `$2`: (tname) Name of the table related with the trigger to drop.
  * `$3`: (avoid_warn) If not empty and trigger doesn't exist no warning
          message are printed.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_drop_trigger
    :end-before: commmons_mariadb_commons_mariadb_drop_trigger_end
```

#### commons_mariadb_drop_event

Drop a event from database if exists.

_Parameters_:

  * `$1`: (ename) name of the event to drop.
  * `$2`: (avoid_warn) If not empty and event doesn't exist no warning
          message are printed.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_drop_trigger
    :end-before: commmons_mariadb_commons_mariadb_drop_trigger_end
```

#### commons_mariadb_show_gvars

Retrieve global variables.

_Parameters_:

  * `$1`: (filter) filter apply to SELECT of variables.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mariadb.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mariadb_commons_mariadb_show_gvars
    :end-before: commmons_mariadb_commons_mariadb_show_gvars_end
```

