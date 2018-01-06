## Oracle Module

Target of this module is supply a tool for simplify development process and source organization.

Main features are:

  * compilation of scripts, packages, views, triggers, functions, jobs, schedulers and
    synonims
  * download from an existing database all functions, packages, triggers
  * simplify access to database between developers and packaging of released versions.

Mission of `dbrm` is NOT create a new IDE for SQL, every users can use any IDE for create tables, functions, etc. but with `dbrm` is it possible unify process for trace database informations and store to a repository in an ordered mode.

### Project Folder Structure

An initialized project folder is composed by these directories:

  * `creation_scripts`: this directory contains initial DDL script for create all
                        tables of the project from zero. This directory could be used
                        at begin of the project for the first release, in the next release
                        is then used *update_scripts* directory that contains script for 
                        upgrade project and trace changes between releasees.
  * `dbrm-profiles`: if profiles are enable contains all configuration files for
                     different environment (dev, test, prod, etc.). This directory could be with
                     a different name and depend of value present of DRM_PROFILES_PATH variable.
  * `functions`: this directory contains files with database functions code
  * `packages`: this directory contains files of all PL/SQL packages present on schema
  * `procedures`: this directory contains files with database procedure code
  * `schemas`: this directory is created automatically when dbrm initialize a directory
               and could be used from users for store database schemas (in my case I use Dia).
  * `triggers`: this directory contains all files for compile all triggers of the
                project database.
  * `update_scripts`: this directory is used for store script with changes on database between
                      first release and next releases.
  * `views`: this directory contains files for compiles project database views
  * `synonims`: this directory contains files for compile synonims
  * `jobs`: this directory contains files for compile jobs
  * `schedulers`: this directory contains files for compile schedulers

Under project directory normally is also available `dbrm.conf` file with main configuration
options of the project and `dbrm.db` sqlite database used by `dbrm` for the project.

### Variables

```eval_rst
  .. list-table::
   :header-rows: 1
   :widths: 10, 20

   * - Variable
     - Description
   * - ``ORACLE_USER``
     - Contains username to use for connection to schema
   * - ``ORACLE_PWD``
     - Contains password to use for connection to schema
   * - ``ORACLE_DB``
     - Contains name of the schema to use
   * - ``ORACLE_SID``
     - Contains name of the SID or Service Name to use on connection.
   * - ``ORACLE_DIR``
     - Contains path of the directory used for store all database scripts.
   * - ``ORACLE_COMPILE_FILES_EXCLUDED``
     - Permit to define a list of script that are present on project directory
       to ignore on compilation process.
   * - ``TNS_ADMIN``
     - Override default TNS_ADMIN Oracle variable where retrieve tnsnames.ora
       file used on connection
```

### Commands

#### oracle version

Show version of oracle module.

```shell
  $# dbrm oracle version
  Version: 0.1.0
```

#### oracle test_connection

Test connection to schema of the active profile or active configuration.

##### test_connection options:

This options are generic option for handle connection and are avilable on different
commands.

  * `-S oracle_sid`: Override Oracle SID (or set ORACLE_SID on configuration file).
  * `-P oracle_pwd`: Override Oracle Password (or set ORACLE_PWD on configuration file).
  * `-U oracle_user`: Override Oracle schema/user (or set ORACLE_USER on configuration file).
  * `-t tnsadmin_path`: Override TNS_ADMIN variable with path of the file tnsnames.ora.
  * `-D oracle_dir`: Directory where save/retrieve packages/views/functions, etc..
                     (or set ORACLE_DIR on configuration file).


```shell
  $# dbrm oracle test_connection
  Connected to openstack_neutron with user neutron correctly.
```

#### oracle shell

Enter on schema shell of the active profile or active configuration.

##### shell options:

This options are generic option for handle connection and are avilable on different
commands.

  * `-S oracle_sid`: Override Oracle SID (or set ORACLE_SID on configuration file).
  * `-P oracle_pwd`: Override Oracle Password (or set ORACLE_PWD on configuration file).
  * `-U oracle_user`: Override Oracle schema/user (or set ORACLE_USER on configuration file).
  * `-t tnsadmin_path`: Override TNS_ADMIN variable with path of the file tnsnames.ora.
  * `-D oracle_dir`: Directory where save/retrieve packages/views/functions, etc..
                     (or set ORACLE_DIR on configuration file).


```shell
  $# dbrm oracle shell
```

#### oracle download

Download packages, triggers, functions, views, jobs and schedulers from database schema of the active profile or configuration.

##### oracle options:

  * `-S oracle_sid`: Override Oracle SID (or set ORACLE_SID on configuration file).
  * `-P oracle_pwd`: Override Oracle Password (or set ORACLE_PWD on configuration file).
  * `-U oracle_user`: Override Oracle schema/user (or set ORACLE_USER on configuration file).
  * `-t tnsadmin_path`: Override TNS_ADMIN variable with path of the file tnsnames.ora.
  * `-D oracle_dir`: Directory where save/retrieve packages/views/functions, etc..
                     (or set ORACLE_DIR on configuration file).
  * `--all-packages`: Download all packages.
  * `--all-triggers`: Download all triggers.
  * `--all-functions`: Download all functions.
  * `--all-views`: Download all views.
  * `--all-jobs`: Download all jobs.
  * `--all-schedules`: Download all schedules.
  * `--all`: Download all.
  * `--package name`: Download a particular package.
  * `--trigger name`: Download a particular trigger.
  * `--function name`: Download a particular function.
  * `--view name`: Download a particular view.
  * `--job name`: Download a particular job.
  * `--schedule name`: Download a particular schedule.

There are many options with `download` command so I propose hereinafter only some
examples.

* Download all packages

```shell
  $# dbrm oracle download --all-packages

```

#### oracle compile

Compile procedures, triggers, views, packages, jobs and schedulers to an active database.

From command line is visible result of compilation but a more detailed trace is save on logfile defined on `LOGFILE` variable
(default `dbrm.log`).

##### compile options:

  * `--all-packages`: Compile all packages present under ORACLE_DIR subdirectories.
  * `--all-triggers`: Compile all triggers present under ORACLE_DIR subdirectories.
  * `--all-functions`: Compile all functions present under ORACLE_DIR subdirectories.
  * `--all-views`: Compile all views present on ORACLE_DIR subdirectories.
  * `--all-jobs`: Compile all jobs present on ORACLE_DIR subdirectories.
  * `--all-schedules`: Compile all schedules present on ORACLE_DIR subdirectories.
  * `--all`: Compile all packages, triggers, functions, views, jobs
             and schedules present under ORACLE_DIR subdirectories.
  * `--package name`: Compile a particular package under ORACLE_DIR/packages directory.
  * `--trigger name`: Compile a particular trigger under ORACLE_DIR/triggers directory.
  * `--function name`: Compile a particular function under ORACLE_DIR/functions directory.
  * `--view name`: Compile a particular view under ORACLE_DIR/views directory.
  * `--job name`: Compile a particular job under ORACLE_DIR/views directory.
  * `--schedule name`: Compile a particular schedule under ORACLE_DIR/views directory.
  * `--exclude filename`: Exclude a particular file from compilation.
                          (This option can be repeat and override
                           ORACLE_COMPILE_FILES_EXCLUDED configuration variable).

  * `--id-script id`: Compile a particular script registered under
                      ORACLE_DIR/<directory>/. This option use dbm database
                      to retrieve script, feature under development.
  * `--file file`: Compile a particular file.
                   (Use ABS Path or relative path from current dir.)

For argument with value if it isn't passed value argument is ignored.

```shell
  $# dbrm oracle compile --all-triggers

```

#### oracle query

This command permit to execute directly a query through shell on active schema.

##### query options;

  * `-S oracle_sid`: Override Oracle SID (or set ORACLE_SID on configuration file).
  * `-P oracle_pwd`: Override Oracle Password (or set ORACLE_PWD on configuration file).
  * `-U oracle_user`: Override Oracle schema/user (or set ORACLE_USER on configuration file).
  * `-t tnsadmin_path`: Override TNS_ADMIN variable with path of the file tnsnames.ora.
  * `-D oracle_dir`: Directory where save/retrieve packages/views/functions, etc..
                     (or set ORACLE_DIR on configuration file).
  * `--stdin-query`: Set this option for query send from standard input.
  * `--logging`: Enable logging of the query to log file
  * `--query QUERY`: Query to execute.
  * `--output-opts OPTS`: Customize sqlplus output options.
                          Default are: set echo off heading off feedback off wrap off.


