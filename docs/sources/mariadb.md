## MariadDB Module

Target of this module is supply a tool for simplify development process and
sources organization.

Main features are:

  * compilation of scripts, indexes, foreign keys, functions, procedures, triggers, views and events
  * download from an existing database all indexes, foreign keys, functions, procedures, triggers, view and events and save it through a fixed structure.
  * create initial DDL script with all tables of an existing database or simplify aligthnement of this file on development process
  * display a list of information of an existing database (list of tables, foreign keys between tables, table size, etc.)
  * drop procedure, functions, index, etc.
  * simplify access to database between developers.
q
Mission of `dbrm` is NOT create a new IDE for SQL, every users can use any IDE for create tables, functions, etc. but with `dbrm` is it possible unify process for trace database informations and store to a repository in an ordered mode.

### Project Folder Structure

An initialized project folder is composed by these directories:

  * `creation_scripts`: this directory contains initial DDL script for create all tables of the project from zero. This directory could be used at begin of the project for the first release, in the next release is then used *update_scripts* directory that contains script for upgrade project and trace changes between releasees.
  * `dbrm-profiles`: if profiles are enable contains all configuration files for different environment (dev, test, prod, etc.)
  * `foreign_keys`: this directory contains files related with all foreign keys of the project's tables
  * `functions`: this directory contains files with database functions code
  * `indexes`: this directory contains files with all indexes of the database.
  * `procedures`: this directory contains files with database procedure code
  * `schemas`: this directory is created automatically when dbrm initialize a directory
               and could be used from users for store database schemas (in my case I use Dia).
  * `triggers`: this directory contains all files for compile all triggers of the
                project database.
  * `update_scripts`: this directory is used for store script with changes on database between
                      first release and next releases.
  * `views`: this directory contains files for compiles project database views.

Under project directory normally is also available `dbrm.conf` file with main configuration
options of the project and `dbrm.db` sqlite database used by `dbrm` for the project.

### Permissions and options required

For permit to normal user of the database to retrieve informations used by `dbrm` it is required set of this *GRANT*:

```shell
mysql> GRANT SELECT ON mysql.proc TO 'project_user'@'127.0.0.1';
```

While, to avoid an error like this on triggers compilation:

*You do not have the SUPER privilege and binary logging is enabled (you *might* want to use the less safe log_bin_trust_function_creators variable)*

it is required add this option to `my.cnf`:

```
log_bin_trust_function_creators = 1;
```

#### Fix for Mysql >= 5.6

From version 5.6 of mysql command line tool is present an annoying
warning message like this:

   *'Warning: Using a password on the command line interface can be insecure.'*
   *when is used a --password argument.*

This warning message broken `dbrm` and it is required add MYSQL5_6_ENV_PWD="1" on `dbrm.conf` file.

### Commands

#### mariadb version

Show version of mariadb module.

```shell
  $# dbrm mariadb version
  Version: 0.1.0
```
