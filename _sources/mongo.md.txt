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
   * - ``MONGO_INITRC``
     - Contains path of the file with content to execute before
       target commands.
```

### Project Folder Structure

An initialized project folder is composed by these directories:

  * `creation_scripts`: this directory contains initial DDL script for create all
                        collection of the project with master data types.
                        This directory could be used at begin of the project for the first
                        release, in the next release is then used *update_scripts* directory
                        that contains script for upgrade project and trace changes between
                        releasees.
  * `dbrm-profiles`: if profiles are enable contains all configuration files for
                     different environment (dev, test, prod, etc.). This directory could be with
                     a different name and depend of value present of DRM_PROFILES_PATH variable.
  * `indexes`: this directory contains files with all indexes of the database.
               Special index _id could be not present.
  * `update_scripts`: this directory is used for store scripts with changes on database between
                      first release and next releases.
  * `schemas`: optinal directory that could be contains database schema of the
               collections for example done by Dia tool.

Under project directory normally is also available `dbrm.conf` file with main configuration
options of the project and `dbrm.db` sqlite database used by `dbrm` for the project.

#### Index Naming Convention

Indexes created with *create* command or downloaded with *download* command has this
naming convention:

```
  filename = <Collection Name> '.' <Index Name> '.js'
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

```shell
  $# dbrm mongo test_connection
  Connected to database1 with user icon correctly.
```

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

```shell
  $# dbrm mongo shell
  MongoDB shell version v3.4.3
  connecting to: mongodb://192.168.1.200:27018/database1
  MongoDB server version: 3.2.11
  WARNING: shell and server versions do not match
  mongos>
```

#### mongo compile

Compile files to active database.

From command line is visible result of compilation but a more detailed trace is save on logfile defined on `LOGFILE` variable
(default `dbrm.log`).

##### compile options:

  * `-P MONGO_PWD`: Override MONGO_PWD variable.
  * `-U MONGO_USER`: Override MONGO_USER with username of the connection.
  * `-H MONGO_HOST`: Override MONGO_HOST with host of the database.
  * `-D MONGO_DIR`: Override MONGO_DIR directory where save/retrieve script/functions, etc.
  * `--database db`: Override MONGO_DB variable for database name.
  * `--conn-options opts`: Override MONGO_EXTRA_OPTIONS variable for enable extra
                           connection options.
  * `--authdb db`: Override MONGO_AUTHDB variable for set authentication database.
 * `--file FILE`: Compile a particular file. (Use ABS Path or relative path from current dir.)

For argument with value if it isn't passed value argument is ignored.

```shell
  $#  dbrm mongo compile --file test.js
  (mongo) Start compilation (file test.js): File test.js
  (mongo) End compilation (file test.js, result => 0): File test.js
  Compile operation successfull.
```

### API

#### mongo_set_auth_var

Set mongo_auth variable with arguments to use with mongo client program.
Valorize options like: -u username --password=pwd database.

Currently, authentication with certificate is not yet supported.

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
    :start-after: mongo_mongo_set_auth_var
    :end-before: mongo_mongo_set_auth_var_end
```

#### mongo_file

Compile a file and save ouput to input variable.

_Parameters_:

  * `$1`: (var) Name of the variable where is save output command.
  * `$2`: (f) File to compile.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/mongo.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: mongo_mongo_file
    :end-before: mongo_mongo_file_end
```

#### mongo_file_initrc

Compile a file and save ouput to input variable.
File is loaded on memory before execute content, so it isn't ideal
for bigfile.

_Parameters_:

  * `$1`: (var) Name of the variable where is save output command.
  * `$2`: (f) File to compile.
  * `$3`: (initrc) Path of file with commons commands to execute before
          compile file content. Is an alternative to .mongorc.js file.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/mongo.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: mongo_mongo_file_initrc
    :end-before: mongo_mongo_file_initrc_end
```

#### mongo_cmd_4var

Execute an input statement on configured schema.

_Variables Used_:
  * `MONGO_CLIENT`: Path of mongo client.

_Parameters_:

  * `$1`: (var) Name of the variable where is save output command.
  * `$2`: (cmd) Command to execute.
  * `$3`: (rm_lf) If string length is not zero than from output command are remove LF.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/mongo.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: mongo_mongo_cmd_4var
    :end-before: mongo_mongo_cmd_4var_end
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

#### commons_mongo_compile_file

Compile a file to current mongodb database.

_Parameters_:

   * `$1`: (file) File to compile.
   * `$2`: (msg) message to write on logfile before and after compilation.
   * `$3`: (use_initrc) Optional argument to force use of mongo_file_initrc (default)
           or mongo_file command if equal to 0.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mongo.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mongo_commons_mongo_compile_file
    :end-before: commons_mongo_commons_mongo_compile_file_end
```
#### commons_mongo_get_indexes_list

Retrieve list of all indexes of current mongodb database and some statistics.
This method store result on associative array with name *mongo_indexes* that
contains these columns:

  * collection: Name of the collection.
  * key: Name of the index
  * keys: list of keys of the index separated by comma
  * n_keys: number of keys of the index
  * keys_complete: list of the index keys on JSON format
  * index size: current index size
  * index options: index options (for example unique, expireAfterSec, etc.)

For identify the size of the array it is needed divide number of records
between number of columns (in this case 7) and then iterate for number of
elements.

```bash
  commons_mongo_get_indexes_list "" "" ""

  local n_indexes=${#mongo_indexes[@]}
  local real_n_indexes=$((n_indexes/7))

  # Retrieve data for every index
  for ((i=0; i<${real_n_indexes}; i++) ; do
      local kcoll=${mongo_indexes[$i, 0]}
      local kname=${mongo_indexes[$i, 1]}
      local n_keys=${mongo_indexes[$i, 3]}
      local keys=${mongo_indexes[$i, 4]}
      local idxsize=${mongo_indexes[$i, 5]}
      local idxopts=${mongo_indexes[$i, 6]}
  done
```

_Parameters_:

   * `$1`: (single_collection) If present permit to retrieve list
           of indexes of a particular collection. If not present or
           equal to empty string than all indexes of database are returned.
   * `$2`: (filter_keyname) Optional argument that permit to filter
           indexes with a particula key name.
   * `$3`: (ignore\_id\_) Optional argument that permit to filter
           special index _id from list. Possible values are 0 (default)
           and 1 (ignore index with key name _id_).

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mongo.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mongo_commons_mongo_get_indexes_list
    :end-before: commons_mongo_commons_mongo_get_indexes_list_end
```

#### commons_mongo_stats

Retrieve statistics data of collections, indexes or custom stats.

_Parameters_:

   * `$1`: (single_collection) If present permit to retrieve data
           of a particular collection. If not present or
           equal to empty string than all collections of database 
           are used for retrieve data.
   * `$2`: (target) Identify type of data returned. Possible values
           are *collection*, *index*, *custom*.
   * `$3`: (custom_content) Optional argument that contains _jq_
           parse string for retrieve a custom data from json stats
           of collection. It is used when target contains *custom*.

Result data are store on `mongo_stats` array.

If target is equal to *collection* then is returned an associative
array with this columns:

  * `collection`: Name of the collection
  * `storageSize`: Storage size of the collection
  * `sharded`: Identify if collection is sharded (1) or not (0)
  * `primary`: If not sharded contains name of the primary node.
  * `count`: Number of documents of the collections.
  * `nindexes`: Number of indexes of the collections.
  * `totalIndexSize`: total size of all indexes of the collection.
  * `capped`: If collection is capped (1) or not (0)
  * `avgObjSize`: contains average document size
  * `size`: size of the collection
  * `sharded nodes`: If sharded list of sharded nodes.

For identify the size of the array it is needed divide number of records
between number of columns (in this case 11) and then iterate for number of
elements.

```bash
  commons_mongo_stats "" "collection"

  local n_colls=${#mongo_stats[@]}
  local real_n_colls=$((n_stats/7))

  # Retrieve data for every collection
  for ((i=0; i<${real_n_colls}; i++) ; do
      local coll=${mongo_stats[$i, 0]}
      local storsize=${mongo_stats[$i, 1]}
      local sharded=${mongo_stats[$i, 2]}
      local primary=${mongo_stats[$i, 3]}
      local count=${mongo_stats[$i, 4]}
      local n_idx=${mongo_stats[$i, 5]}
      local totIdx=${mongo_stats[$i, 6]}
      local capped=${mongo_stats[$i, 7]}
      local avgObjSize=${mongo_stats[$i, 8]}
      local size=${mongo_stats[$i, 9]}
      local shardedNodes=${mongo_stats[$i, 10]}
  done
```

If target is equal to *index* then is returned an associative
array with this columns:

  * `index size`: Size of the index.

and where key of the array is composed by *collection name* and *index key
name*.

```bash
  commons_mongo_stats "" "index"

  # Found index size of key "index1" and collection "c1"
  cal indexSize=${mongo_stats["c1", "index1"]}
```
If target is equal to *custom* then is returned an associative
array with this columns:

  * `collection`: Name of the collection
  * `json`: Custom json content returned by input js string.

For identify the size of the array it is needed divide number of records
between number of columns (in this case 2) and then iterate for number of
elements.

```bash
  commons_mongo_stats "" "custom" ".wiredTiger.cache"

  local n_colls=${#mongo_stats[@]}
  local real_n_colls=$((n_stats/2))

  # Retrieve data for every collection
  for ((i=0; i<${real_n_colls}; i++) ; do
      local coll=${mongo_stats[$i, 0]}
      local custom_json=${mongo_stats[$i, 1]}
  done
```

_Returns_:

  * `0`: on success
  * `1`: on error


```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mongo.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mongo_commons_mongo_stats
    :end-before: commons_mongo_commons_mongo_stats_end
```

#### commons_mongo_create_index_file

Create index file for compilation under `$MONGO_DIR`/indexes directory.
This function create only the file without execute it on database.

_Parameters_:

  * `$1`: (coll) name of the collection where create index.
  * `$2`: (name) Name of the index to create.
  * `$3`: (keys) list of keys as json content to use for create index.
  * `$4`: (opts) list of key options on json format to use on creation script.

_Returns_:

  * `0`: on success
  * `1`: on error

```bash
  # Create index for collection c1 for fiedl f1 with option unique.
  commons_mongo_create_file "c1" "indexf1" "{f1:-1}" "{\"unique\":true}"
```

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mongo.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mongo_commons_mongo_create_index_file
    :end-before: commons_mongo_commons_mongo_create_index_file_end
```

#### commons_mongo_download_index

Download and index configuration and create a creation script under `$MONGO_DIR/indexes directory.

_Parameters_:

  * `$1`: (coll) name of the collection where download index data.
  * `$2`: (kname) Name of the index to download.
  * `$3`: (arr_pos) Optional parameter that contains position of the
                    index to download when there is already an valorized
                    array mongo_indexes previously initialized.
                    If not present function download indipendently
                    index data through commons_mongo_get_indexes_list
                    function.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mongo.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mongo_commons_mongo_download_index
    :end-before: commons_mongo_commons_mongo_download_index_end
```

#### commons_mongo_download_all_indexes

Download all indexes to MONGO_DIR/indexes directory.

_Parameters_:

  * `$1`: (collection) download all indexes of input collection.
          Empty string means all indexes.
  * `$2`: (include\_id\_) Optional parameter that could be
          set to 0 (default value) when special index _id
          are ignored from download or set 1 when on download
          are created also files related with special index _id.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mongo.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mongo_commons_mongo_download_all_indexes
    :end-before: commmons_mongo_commons_mongo_download_all_indexes_end
```

#### commons_mongo_drop_index

Drop a index from database if exists.

_Parameters_:

  * `$1`: (coll) name of the collection where drop index.
  * `$2`: (kname) Name of the index to drop. If not present
                  then all indexes of the collection are dropped.
                  Excluded special index that can be removed
                  only for capped collection.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mongo.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commmons_mongo_commons_mongo_drop_index
    :end-before: commmons_mongo_commons_mongo_drop_index_end
```

#### commons_mongo_compile_idx

Compile file related with index of a collection..

_Parameters_:

  * `$1`: (f) path of the file to compile
  * `$2`: (msg) message to insert on logging file relative to input file
  * `$3`: (force) if index is present and force is equal to 1, then
          index is dropped and added again. NOT IMPLEMENTED.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mongo.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mongo_commons_mongo_compile_idx
    :end-before: commons_mongo_commons_mongo_compile_idx_end
```

#### commons_mongo_compile_all_from_dir

Compile all files from input directory with .js extension.

_Parameters_:

  * `$1`: (directory) Directory where there are files to compile.
  * `$2`: (msg_head) Title message insert on logfile before compile files.
  * `$3`: (msg) message insert on logfile before compile files.
  * `$4`: (type) Identify type of directory: idx or empty.
          Optional.
  * `$5`: (closure) custom parameter with a value relative to type.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mongo.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mongo_commons_mongo_compile_all_from_dir
    :end-before: commons_mongo_commons_mongo_compile_all_from_dir_end
```

#### commons_mongo_compile_all_idxs

Compile all files under `$MONGO_DIR`/indexes directory.

_Parameters_:

  * `$1`: (msg) message to insert on logging file relative to input file.
  * `$2`: (force) if equals to 1, force compilation of all indexes also
          if already present.

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_mongo.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_mongo_commons_mongo_compile_all_idxs
    :end-before: commons_mongo_commons_mongo_compile_all_idxs_end
```
