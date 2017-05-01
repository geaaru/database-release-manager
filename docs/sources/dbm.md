
## DBM Module

Core module that contains features for manage `dbrm` configuration and projects management.
Currently, only management of profiles is a stable features; all others features to store and manage scripts and releases are under heavy development.

### Variables

```eval_rst
  .. list-table::
   :header-rows: 1
   :widths: 10, 20

   * - Variable
     - Description
   * - ``DEBUG``
     - Contains a Boolean value for enable/disable debugging output.
   * - ``MODULES_DIR``
     - Contains path where retrieve dbrm modules files. Normally is set in general configuration file under /etc/dbrm.conf
   * - ``LOCAL_DIR``
     - Contains directory path of the project to manage.
   * - ``LOCAL_CONFIG_FILE``
     - Through this variable is possible override and customize dbrm properties set on generic configuration file.
   * - ``DRM_DB``
     - Contains path of Sqlite internal database used by dbrm. Default path is *$HOME/.local/share/dbrm/dbrm.db*
   * - ``SQLCA``
     - SQLCA (SQL Connector Adapter) contains list of database enabled adapters. Multiple adapters are seperated by pipe (`|`).
       Example: `oracle|mariadb`
   * - ``DRM_PROFILE``
     - Enable (value 1) or Disable (value 0 or variable not set) DBM Profiles Feature. Normally used to manage different configuration files for
       every environment (dev, test, production, etc.)
   * - ``DRM_PROFILES_PATH``
     - Define directory path used by `dbrm` as prefix path of profile files.
       Default path is: *$HOME/.local/share/dbrm/profiles*.
   * - ``DBM_HISTORY``
     - Contains history of all execute command by dbrm. (Under development: Not all modules store on history).
   * - ``DBM_UNDO_SCRIPT``
     - Contains path of the file where dbrm write undo command to revert changes done.
       (Under development: not all modules write to *undo* files)
```

### Commands

#### dbm version

Show version of dbm module.

```shell
  $# dbrm dbm version
  Version: 0.1.0
```

#### dbm info

Show active parameters of dbrm module.

```shell
  $# dbrm dbm info
  LOCAL_DIR = /tmp/database-release-manager
  LOCAL_CONFIG_FILE = /home/geaaru/.local/share/dbrm/dbrm.conf
  MODULES_DIR = /usr/share/dbrm/modules
  SQLCA = sqlite|mariadb|psql
  DRM_DB = ./test.db
  DBM_HISTORY = /tmp/database-release-manager/.dbm_history
  DRM_PROFILE = 1
  DRM_PROFILES_PATH = /home/geaaru/.local/share/dbrm/profiles
  MARIADB_USER = root
  MARIADB_PWD = pwd
  MARIADB_DB = test
  MARIADB_HOST =
  MARIADB_DIR = .
  MARIADB_TMZ = UTC
  MARIADB_COMPILE_FILES_EXCLUDED =
  MARIADB_EXTRA_OPTIONS =
  MARIADB_ENABLE_COMMENTS =
  SQLITEDB = ./test.db

```

TODO:
* Execute call of info modules to every connector adapter without statically manage it inside this function.


#### dbm initenv

Create a new empty dbrm database and copy example file of dbrm.conf on new project directory.

##### initenv options:

* `--to-current-dir`: Initialize dbrm stuff on current directory [.]. If this option is used is not possible use
                      --to-dir option.
* `--to-dir <TARGET_DIR>`: Initialize dbrm stuff on a target directory passed in input.
* `--enable-profiles`: Enable Profiles Features on new project.
* `--help|-h`: Show initenv command options.

_Exit Values_:

  * `1`: On error or if a dbrm.conf file or dbrm.db file is already present.
  * `0`: On success

```shell
  $# dbrm dbm initenv --help
  [--to-current-dir]      Initialize current directory [.].
  [--to-dir target]       Initialize target directory.
  [--enable-profiles]     Enable profiles mode and create related directories.
  [--help|-h]             Show help message.

  $# dbrm dbm initenv --to-dir /tmp/dbrm --enable-profiles 
  Creating database /tmp/dbrm/dbrm.db...OK
  Created profile 1.
  Directory is now initialized.
  Modify dev.conf file under dbrm-profile directory for complete configuration.

```

TODO:
* Add option to initialized initenv method of a list of connection adapters.

#### dbm shell

Enter on dbm sqlite database file.

_Exit Values_:

  * `1`: On error
  * `0`: On success

```shell
$# dbrm dbm shell
SQLite version 3.13.0 2016-05-18 10:57:30
Enter ".help" for usage hints.
sqlite>
```

#### dbm show_profiles

Show list of configured profiles. This method is used only if Profiles Feature is enabled.

_Exit Values_:

  * `1`: On error
  * `0`: On success

```shell

  $# dbrm dbm show_profiles
  ===============================================================================================================
  ID      PROFILE_NAME           DEFAULT        CONFIG_FILE            CREATION_DATE          UPDATE_DATE
  ===============================================================================================================
  1       test1                                test.conf              2015-01-18 15:17:43    2015-01-18 21:25:25
  2       dev                   *              dev.conf               2015-01-18 16:59:17    2015-01-18 21:29:57

```

On example, files test.conf and dev.conf must be under directory defined by *DRM_PROFILES_PATH* variable.

#### dbm show_releases

Show releases history.

##### show_releases options:

* `-b ID_BRANCH`: Filter list for a particular Branch Id.
* `-h`: Show show_releases command options.

_Exit Values_:

  * `1`: On error
  * `0`: On success

```shell

  $# dbrm dbm show_releases
  ===============================================================================================================
  ID    RELEASE_DATE          VERSION  UPDATE_DATE          ADAPTER   ID_ORDER  BRANCH  DIRECTORY  NAME
  ===============================================================================================================
  1     2013-05-05 20:41:29   0.1.0    2013-05-08 13:04:56  oracle    1         1       .          Test Platform
  4     2013-05-06 14:50:29   0.1.1    2013-11-18 01:11:35  oracle    1         2       .          Test Platform
  9     2013-11-18 01:09:14   0.2.0    2013-11-18 01:09:14  oracle    2         1       .          Test Platform
  5     2013-11-18 00:33:10   0.1.2    2013-11-18 01:11:35  oracle    2         2       .          Test Platform
  12    2013-11-18 00:00:01   0.3.0    2013-11-18 01:15:47  oracle    3         1       .          Test Platform
  13    2013-11-18 00:00:01   0.4.0    2013-11-18 01:15:47  oracle    4         1       .          Test Platform

```

TODO:
 * Manage help message like other modules with both -h and --help options.

#### dbm show_scripts

Show list of scripts configured and assigned to a release.

_Exit Values_:

  * `1`: On error
  * `0`: On success

```shell

  $# dbrm dbm show_scripts
  ===============================================================================================================
  ID  TYPE           ACTIVE  DIRECTORY           ID_RELEASE  ID_ORDER  UPDATE_DATE             FILENAME
  ===============================================================================================================
  1   update_script  1       update_script/      1           1         2013-05-05 21:26:37     update__0.1.0.sql
  6   update_script  1       update_script/      4           1         2013-05-06 14:52:30     patch_0_1.1.sql
  4   update_script  1       update_script/      9           1         2014-02-03 16:25:45     update_0.2.0.sql
  5   update_script  1       update_script/      12          1         2014-02-03 16:25:21     update_0.3.0.sql

```

TODO:
 * Manage help message like other modules with both -h and --help options.
 * Add filter options (for id release, filename, etc.)

#### dbm show_script_types

Show list of script types.

_Exit Values_:

  * `1`: On error
  * `0`: On success

```shell

  $# dbrm dbm show_script_types
  ===============================================================================================================
  CODE                DESCRIPTION
  ===============================================================================================================
  foreign_key         Foreign Key Script
  function            Function definition script
  initial_ddl         Initial DDL Script
  insert              Insert on table script
  package             Package definition script
  procedure           Procedure definition script
  sequence            Sequences Script
  trigger             Trigger Script
  type                Types Script (For example for a TYPE definition on Oracle)
  update_script       Update Script
  view                View definition script

```

#### dbm show_rel_dep

Show list of releases dependencies with scripts.

_Exit Values_:

  * `1`: On error
  * `0`: On success

```shell

  $# dbrm dbm show_rel_dep
  ===============================================================================================================
  ID_RELEASE     DEPENDENCY     CREATION_DATE
  ===============================================================================================================
  2              1              2013-05-05 21:58:58
  3              1              2013-05-05 21:59:10
  3              2              2013-05-05 21:58:53
  3              4              2013-05-06 14:55:01

```

#### dbm show_inhibit_scripts

Show list of inhibitions scripts between releases.

_Exit Values_:

  * `1`: On error
  * `0`: On success

```shell

  $# dbrm dbm show_inhibit_scripts
  ===============================================================================================================
  ID_SCRIPT       ID_RELEASE_FROM ID_RELEASE_TO   CREATION_DATE
  ===============================================================================================================
  6               1               2               2013-05-05 23:33:12

```

#### dbm show_rel_ded_scripts

Show list of release dedicated scripts.

_Exit Values_:

  * `1`: On error
  * `0`: On success

```shell
  $# dbrm dbm show_rel_ded_scripts
  No scripts available.

```

#### dbm show_adapters

Show list of adapters availables.

_Exit Values_:

  * `1`: On error
  * `0`: On success

```shell
  $ dbrm dbm show_adapters
  ===============================================================================================================
  ADAPTER        DESCRIPTION
  ===============================================================================================================
  mariadb        MySQL/MariaDb Database Adapter
  oracle         Oracle Database Adapter
  sqlite         SQLite Database Adapter

```

#### dbm move_release

Move release position of the same Branch.

##### move_release options:

* `-r VERSION`: Version of the release to move
* `-n NAME`: Name of the release to move
* `-a VERSION_TO`: Move selected release *after* VERSION_TO
* `-b VERSION_TO`: Move selected release *before* VERSION_TO
* `-h`: Show move_release command options.

_Exit Values_:

  * `1`: On error.
  * `0`: On success

TODO:
 * add long options arguments.

#### dbm update_release

Update information about a particular release.

##### update_release options:

* `-n NAME`: Name of the release to update.
* `-v VERSION`: Version of the release to update.
* `-d YYYY-MM-DD`: Date of the release to update.
* `-a ADAPTER`: Adapter value to update on release.
* `-b ID_BRANCH`: Branch Id value to update on release.
* `-i ID_RELEASE`: Id of the release to update
* `--dir DIR`: Directory of the release to update
* `-h`: Show update_release command options.


_Exit Values_:

  * `1`: On error.
  * `0`: On success

```shell
  $# dbrm dbm update_release -i 5 -a oracle -d ./0.1.2
  Release 5 updated correctly.
```

#### dbm add_profile

Insert a new configuration profile.

##### app_profile options:

* `--name NAME`: Name of the profile to insert.
* `--file FILE`: Configuration file to use on new profile. FILE contains only filename.
* `--default`: Enable new profile as default.
* `-h`: Show app_profile command options.

_Exit Values_:

  * `1`: On error.
  * `0`: On success

```shell
  $# dbrm dbm add_profile --name test_profile --file profile1.conf
  Created profile 7.

```

#### dbm del_profile

Delete a configured profile.

##### del_profile options:

* `--name NAME`: Name of the profile to delete.
* `--id ID_PROFILE`: Id of the profile to delete
* `-h`: Show del_profile command options.

_Exit Values_:

  * `1`: On error.
  * `0`: On success

```shell
  $# dbrm dbm del_profile --id 7
  Profile 7 is been deleted.

```

#### dbm set_profile

Set default profile.

##### set_profile options:

* `--name PROFILE_NAME`: Name of the profile to set.
* `--id ID_PROFILE`: Id of the profile to set.
* `-h`: Show set_profile command options.

_Exit Values_:

  * `1`: On error.
  * `0`: On success

```shell
  $# dbrm dbm set_profile --id 7
  Profile 7 is now set as default.

```

#### dbm insert_release

Insert a new release to project.

##### insert_release options:

* `-n RELEASE_NAME`: Name of the release to add.
* `-d YYYY-MM-DD`: Release date of the release to add.
* `-v VERSION`: Version of the release to add.
* `-a ADAPTER`: Adapter used by the release to add (default is oracle).
* `-o ID_ORDER`: Id order of the release to add.
* `-b BRANCH_ID`: Id of the branch connected to release to add.
* `-dir DIRECTORY`: Directory of the release to add.
* `-h`: Show insert_release command options.

_Exit Values_:

  * `1`: On error.
  * `0`: On success

```shell
  $# dbrm dbm insert_release
  [-n name]               Release Name.
  [-d YYYY-MM-DD]         Release Date. (Use now if not available)
  [-v version]            Release Version
  [-a adapter]            Release Adapter (default is Oracle).
  [-o id_order]           Release Id Order (optional).
  [-b id_branch]          Release Id Branch (default master branch {1}).
  [--dir directory]        Release directory (default is [.]).

  $# dbrm dbm insert_release -n 'Project1' -d 2017-04-24 -v 1.2.3 -a mariadb --dir .
  Release Project1 v. 1.2.3 insert correctly.
```

#### dbm remove_release

Remove a release from project.

##### remove_release options:

* `-r RELEASE_ID`: Id of the release to remove.
* `-f`: For remove of the selected release without confirmation question.
* `-h`: Show remove_release command options.

_Exit Values_:

  * `1`: On error.
  * `0`: On success

```shell
  $# dbrm dbm remove_release
  [-r id_release]         Id Release of the script to remove.
  [-f]                    Force remove without confirmation question.

  $# dbrm dbm remove_release -r 15
  Are you sure to remove release with id 15? [N/y]y
  Release 15 is been removed.
```
TODO:
 * use also long options for command arguments.

#### dbm remove_script

Remove a script from project.

##### remove_script options:

* `-i SCRIPT_ID`: Id of the script to remove.
* `-h`: Show remove_script command options.

_Exit Values_:

  * `1`: On error.
  * `0`: On success

```shell
  $# dbrm dbm remove_script
  [-i id_script]          Id Script of the script to remove.

  $# dbrm dbm remove_script -i 10
  Script 10 removed correctly.
```

TODO:
 * use also long options for command arguments.

#### dbm update_script

Update information about a script.

##### update_script options:

* `-i SCRIPT_ID`: Id of the script to update.
* `-f FILENAME`: Script filename to update.
* `-n NAME`: Name of the release of the script to update.
* `-v VERSION`: Version of the release of the script to update.
* `-t STYPE`: Type of the script to update
* `-a FLAG`: Set active (1) or disable (0) flag of the script.
* `-d DIRECTORY`: Directory of the script to update.
* `-o ID_ORDER`: Id order of the script to update (optional).
* `-r RELEASE_ID`: Id of the release of the script.
                   If this option is present are not needed release name and release version.
* `-h`: Show update_script command options.

_Exit Values_:

  * `1`: On error.
  * `0`: On success

```shell
  $# dbrm dbm update_script -h
  [-i id_script]          Id Script.
  [-f filename]           Script filename.
  [-n name]               Release Name.
  [-v version]            Release Version
  [-t script_type]        Script Type.
  [-a 0|1]                Set active flag.
  [-d directory]          Directory of the script.
  [-o id_order]           Script Id Order (optional). Default is used MAX(id) of the same id_release.
  [-r id_release]         Id_release of the script. Use this instead of release name and version.

  $# dbrm dbm update_script -i 10 -a 1
  Script 10 updated correctly.
```

TODO:
 * use also long options for command arguments.

#### dbm insert_script

Insert a new script to a release.

##### insert_script options:

* `-f FILENAME`: Script filename.
* `-n NAME`: Name of the release of the script to insert.
* `-v VERSION`: Version of the release of the script to insert.
* `-t STYPE`: Type of the script to insert.
* `-a FLAG`: Set active (1) or disable (0) flag of the script.
* `-d DIRECTORY`: Directory of the script to insert.
* `-o ID_ORDER`: Id order of the script to update (optional).
                 Default is used MAX(id) of the same id_release.
* `-r RELEASE_ID`: Id of the release of the script.
                   If this option is present are not needed release name and release version.
* `-h`: Show insert_script command options.

_Exit Values_:

  * `1`: On error.
  * `0`: On success

```shell
  $# dbrm dbm insert_script
  [-f filename]           Script filename.
  [-n name]               Release Name.
  [-v version]            Release Version
  [-t script_type]        Script Type.
  [-a 0|1]                Set active flag. Default is 1 (active)
  [-d directory]          Directory of the script.
  [-o id_order]           Script Id Order (optional). Default is used MAX(id) of the same id_release.
  [-r id_release]         Id_release of the script. Use this instead of release name and version.
  [-h]                    Show this message.

  $# dbrm dbm insert_script -f script1.sql -a 1 -r 10 -t update_script
  Script script1.sql insert correctly.
```

TODO:
 * use also long options for command arguments.

#### dbm insert_script_type

Insert a script type.

##### insert_script_type options:

* `-c CODE`: String used as code of the script type.
* `-d DESCRIPTION`: Description of the script type.
* `-h`: Show insert_script_type command options.

_Exit Values_:

  * `1`: On error.
  * `0`: On success

```shell
  $# dbrm dbm insert_script_type
  [-c code]               Script Type Code.
  [-d description]        Script Type Description

  $# dbrm dbm insert_script_type -c regression_test -d 'Script used for check regression issue'
  Script Type regression_test insert correctly.
```
TODO:
 * use also long options for command arguments.

#### dbm insert_rel_dep

Insert a release dependency.

##### insert_rel_dep options:

* `-n NAME`: Name of the release where add a new dependency.
* `-t VERSION_TO`: Version of the release that has a dependency.
* `-f VERSION_FROM`: Version of the release that is needed for VERSION_TO.
* `-h`: Show insert_rel_dep command options.

_Exit Values_:

  * `1`: On error.
  * `0`: On success

```shell
  $# dbrm dbm insert_rel_dep -h
  [-n name]               Release Name.
  [-t version_to]         Release version that has a dependency.
  [-f version_from]       Release version needed.

  $# dbrm dbm insert_rel_dep -n 'Project1' -t '0.1.1' -f '0.1.0'
  Insert release dependency to Project1 v.0.1.1 correctly.
```
TODO:
 * use also long options for command arguments.


#### dbm remove_rel_dep

Remove a release dependency.

##### remove_rel_dep options:

* `-n NAME`: Name of the release where remove dependency.
* `-t VERSION_TO`: Version of the release that has a dependency.
* `-f VERSION_FROM`: Version of the release that is needed for VERSION_TO.
* `-h`: Show remove_rel_dep command options.

_Exit Values_:

  * `1`: On error.
  * `0`: On success

```shell
  $# dbrm dbm remove_rel_dep -h
  [-n name]               Release Name.
  [-t version_to]         Release version that has a dependency.
  [-f version_from]       Release version needed.

  $# dbrm dbm remove_rel_dep -n 'Project1' -t '0.1.1' -f '0.1.0'
  Remove release dependency to Project1 v.0.1.1 with 0.1.0 correctly.
```
TODO:
 * use also long options for command arguments.

#### dbm insert_inhibit_script

Insert a release inhibited script.

##### insert_inhibit_script options:

* `-n NAME`: Name of the release where add an inhibited script between two version.
* `-i SCRIPT_ID`: Id of the script to inhibit.
* `-t VERSION_TO`: Version of the release target of the installation.
* `-f VERSION_FROM`: Version of the release source of the installation.
* `-h`: Show insert_inhibit_script command options.

_Exit Values_:

  * `1`: On error.
  * `0`: On success

```shell
  $# dbrm dbm insert_inhibit_script -h
  [-n name]               Release Name.
  [-i id_script]          Script Id.
  [-t version_to]         Release version target of the installation.
  [-f version_from]       Release version source of the installation.

  $# dbrm dbm insert_inhibit_script -n 'Project1' -t '0.2.0' -f '0.1.0' -i 10
  Record insert correctly.
```

TODO:
 * use also long options for command arguments.


#### dbm insert_ded_script

Insert a release dedicated script.

##### insert_ded_script options:

* `-n NAME`: Name of the release where add an dedicated script between two version.
* `-i SCRIPT_ID`: Id of the script to insert.
* `-t VERSION_TO`: Version of the release target of the installation.
* `-f VERSION_FROM`: Version of the release source of the installation.
* `-h`: Show insert_ded_script command options.

_Exit Values_:

  * `1`: On error.
  * `0`: On success

```shell
  $# dbrm dbm insert_ded_script -h
  [-n name]               Release Name.
  [-i id_script]          Script Id.
  [-t version_to]         Release version target of the installation.
  [-f version_from]       Release version source of the installation.

  $# dbrm dbm insert_ded_script -n 'Project1' -t '0.2.0' -f '0.1.0' -i 10
  Record insert correctly.
```

TODO:
 * use also long options for command arguments.

#### dbm remove_inhibit_script

Remove a release inhibited script.

##### remove_inhibit_script options:

* `-n NAME`: Name of the release where remove an inhibited script between two version.
* `-i SCRIPT_ID`: Id of the script to remove.
* `-t VERSION_TO`: Version of the release target of the installation.
* `-f VERSION_FROM`: Version of the release source of the installation.
* `-h`: Show remove_inhibit_script command options.

_Exit Values_:

  * `1`: On error.
  * `0`: On success

```shell

  $# dbrm dbm remove_inhibit_script -h
  [-n name]               Release Name.
  [-i id_script]          Script Id.
  [-t version_to]         Release version target of the installation.
  [-f version_from]       Release version source of the installation.

  $# dbrm dbm remove_ded_script -n 'Project1' -t '0.2.0' -f '0.1.0' -i 10
  Record removed correctly.
```

TODO:
 * use also long options for command arguments.

#### dbm remove_ded_script

Remove a release inhibited script.

##### remove_ded_script options:

* `-n NAME`: Name of the release where remove a dedicated script between two version.
* `-i SCRIPT_ID`: Id of the script to remove.
* `-t VERSION_TO`: Version of the release target of the installation.
* `-f VERSION_FROM`: Version of the release source of the installation.
* `-h`: Show remove_ded_script command options.

_Exit Values_:

  * `1`: On error.
  * `0`: On success

```shell
  $# dbrm dbm remove_ded_script -h
  [-n name]               Release Name.
  [-i id_script]          Script Id.
  [-t version_to]         Release version target of the installation.
  [-f version_from]       Release version source of the installation.

  $# dbrm dbm remove_dev_script -n 'Project1' -t '0.2.0' -f '0.1.0' -i 10
  Record removed correctly.
```
TODO:
 * use also long options for command arguments.


#### dbm show_branches

Show list of branches.

_Exit Values_:

  * `1`: On error.
  * `0`: On success

```shell
  $# dbrm dbm show_branches
  ===============================================================================================================
  ID        CREATION_DATE           UPDATE_DATE             NAME
  ===============================================================================================================
  1         2013-05-21 08:41:52     2013-05-21 08:41:52     master
  2         2013-11-18 00:27:57     2013-11-18 00:27:57     0.1.x

```

#### dbm insert_branch

Insert a new branch.

##### insert_branch options:

* `-n NAME`: Name of the branch to insert.
* `-d YYYY-MM-DD`: Date of the branch (optional). Default valeu is now.
* `-h`: Show insert_branch command options.

_Exit Values_:

  * `1`: On error.
  * `0`: On success

```shell
  $# dbrm dbm insert_branch
  [-n name]               Branch Name.
  [-d YYYY-MM-DD]         Branch Date. (Use now if not available)

  $# dbrm dbm insert_branch -n 'master'
  Branches master insert correctly.
```
TODO:
 * use also long options for command arguments.

#### dbm move_script

Move a release script.

##### move_script options:

* `-i SCRIPT_ID`: Id of the script to move.
* `-a SCRIPT_ID_X`: Move script *after* script with id SCRIPT_ID_X.
* `-b SCRIPT_ID_X`: Move script *before* script with id SCRIPT_ID_X.
* `-r ID_RELEASE`: Release id of the script to move.
* `-h`: Show move_script command options.

_Exit Values_:

  * `1`: On error.
  * `0`: On success

```shell
  $# dbrm dbm move_script -h
  [-i id_script]          Id script of the script to move.
  [-a x]                  After script with id x.
  [-b x]                  Before script with id x.
  [-r id_release]         Id Release of the script to move.

  $# dbrm dbm move_script -i 10 -a 11 -r 1
  Moved correctly script 10 of the release 1 after script 11.
```
TODO:
 * use also long options for command arguments.

#### dbm upgrade

Upgrade DBRM database with last revision.

_Exit Values_:

  * `1`: On error.
  * `0`: On success

### API

#### _dbm_init

Method called when module dbm is initialized.
Load all \*.inc files of dbm module that contains help messages and command line parser of the dbm module commands.

_Returns_:

  * `0`: always

```eval_rst
.. hidden-literalinclude:: ../../modules/dbm.mod.in
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_init
    :end-before: dbm__dbm_init_end
```

#### _dbm_post_init

Internal function called after initialization of dbm module.
On this function is:
* check if exists internal sqlite database (DRM_DB variable) otherwise is created.
* check if it is defined DBM_UNDO_SCRIPT variable relative to undo commands.
  If is not defined then $LOCAL_DIR/dbm_undo.sh script file is used.
* check if it is defined DBM_HISTORY variable relative to command history log.
  If is not defined then $LOCAL_DIR/.dbm_history file is used.

```eval_rst
.. hidden-literalinclude:: ../../modules/dbm.mod.in
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_post_init
    :end-before: dbm__dbm_post_init_end
```

#### _dbm_upgrade

Internal function called by upgrade command that upgrade and/or verify
DBRM database file.

```eval_rst
.. hidden-literalinclude:: ../../modules/dbm.mod.in
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_upgrade
    :end-before: dbm__dbm_upgrade_end
```

#### _dbm_how_many_profiles

Internal function that count number of configured profiles.

_Return_:

  * `0`: on success. Store number profiles on _sqlite_ans variable.
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_tools.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_how_many_profiles
    :end-before: dbm__dbm_how_many_profiles_end
```
#### _dbm_get_profile_by_name

  Store on `DRM_PROFILE_FILE` variable complete path of the configuration file of the
  profile with name passed in input.
  Check also if file exists.

_Parameters_:

  * `$1`:  name of the profile

_Return_:

  * `0`: on success. Set DRM_PROFILE_FILE variable.
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_tools.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_get_profile_by_name
    :end-before: dbm__dbm_get_profile_by_name_end
```

#### _dbm_get_default_profile_filepath

  Store on `DRM_PROFILE_FILE` variable complete path of the configuration
  file of the active profile.
  Check also if file exists.

_Return_:

  * `0`: on success. Set DRM_PROFILE_FILE variable.
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_tools.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_get_default_profile_filepath
    :end-before: dbm__dbm_get_default_profile_filepath_end
```

#### _dbm_check_if_exist_prof_byid

  Check if exists a profile by Id.

_Parameters_:

  * `$1`:  id of the profile to check.

_Return_:

  * `0`: profile exists.
  * `1`: profile not exists.

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_tools.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_check_if_exist_prof_byid
    :end-before: dbm__dbm_check_if_exist_prof_byid_end
```

#### _dbm_check_if_exist_prof_byname

  Check if exists a profile by name.

_Parameters_:

  * `$1`:  Name of the profile to check.

_Return_:

  * `0`: profile exists.
  * `1`: profile not exists.

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_tools.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_check_if_exist_prof_byname
    :end-before: dbm__dbm_check_if_exist_prof_byname_end
```

#### _dbm_check_if_exist_rel

  Check if exists release by name and version.

_Parameters_:

  * `$1`: Name of the release to check.
  * `$2`: Version of the release to check

_Return_:

  * `0`: release is present.
  * `1`: release is not present.

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_tools.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_check_if_exist_rel
    :end-before: dbm__dbm_check_if_exist_rel_end
```

#### _dbm_retrieve_script_data

  Retrieve script data.
  If second parameter is valorized then are set these variables:

  * `DBM_SCRIPT_ID`: Script Id
  * `DBM_SCRIPT_FILENAME`: Script filename
  * `DBM_SCRIPT_TYPE`: Script type string.
  * `DBM_SCRIPT_ACTIVE`: Active flag
  * `DBM_SCRIPT_DIR`: Directory of the script.
  * `DBM_SCRIPT_ID_RELEASE`: Id of the release connected to script.
  * `DBM_SCRIPT_ID_ORDER`: Id Order of the script.
  * `DBM_SCRIPT_REL_NAME`: Release name connected to script.
  * `DBM_SCRIPT_REL_VERSION`: Release version connected to script.
  * `DBM_SCRIPT_ADAPTER`: adapter of the script.

_Parameters_:

  * `$1`: Script Id
  * `$2`: Set 1 or to a string with a len grether then 0 to set described variables.

_Return_:

  * `0`: on sucess
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_tools.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_retrieve_script_data
    :end-before: dbm__dbm_retrieve_script_data_end
```
   
#### _dbm_retrieve_first_release

  Retrieve first release data by release/project name.
  If release is present then are valorized these variables:

  * `DBM_REL_ID_RELEASE`: Id of the release.
  * `DBM_REL_VERSION`: Version of the release.

_Parameters_:

  * `$1`: Name of the release/project.

_Return_:

  * `0`: on sucess
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_tools.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_retrieve_first_release
    :end-before: dbm__dbm_retrieve_first_release_end
```

#### _dbm_check_if_exist_id_script

  Check if exists a script by Id.

_Parameters_:

  * `$1`: Id of the script
  * `$2`: Id of the release (optional).

_Return_:

  * `0`: script is present.
  * `1`: script isn't present. (An exit 1 command is call if not present)

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_tools.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_check_if_exist_id_script
    :end-before: dbm__dbm_check_if_exist_id_script_end
```
#### _dbm_check_if_exist_id_branch

  Check if exists a branch with input id.

_Parameters_:

  * `$1`: Id of the branch

_Return_:

  * `0`: branch is present
  * `1`: branch isn't present. (An exit 1 command is call if not present)

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_tools.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_check_if_exist_id_branch
    :end-before: dbm__dbm_check_if_exist_id_branch_end
```

#### _dbm_check_if_exist_id_rel

  Check if exists a release with input id.

_Parameters_:

  * `$1`: Id of the release

_Return_:

  * `0`: release is present
  * `1`: release isn't present. (An exit 1 command is call if not present)

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_tools.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_check_if_exist_id_rel
    :end-before: dbm__dbm_check_if_exist_id_rel_end
```
#### _dbm_retrieve_field_rel

  Retrieve a list of fields related with a release (by name and version).
  On success, data are available through `_sqlite_ans` variable

_Parameters_:

  * `$1`: a list of fields separeted by , to retrieve
  * `$2`: name of the release
  * `$3`: version of the release.

_Return_:

  * `0`: on success
  * `1`: on error. (An exit 1 command is call if no data are found)

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_tools.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_retrieve_field_rel
    :end-before: dbm__dbm_retrieve_field_rel_end
```
#### _dbm_retrieve_field_rel_byid

  Retrieve a list of fields related with a release (by id)
  On success, data are available through `_sqlite_ans` variable

_Parameters_:

  * `$1`: a list of fields separeted by , to retrieve
  * `$2`: id of the release

_Return_:

  * `0`: on success
  * `1`: on error. (An exit 1 command is call if no data are found)

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_tools.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_retrieve_field_rel_byid
    :end-before: dbm__dbm_retrieve_field_rel_byid_end
```

#### _dbm_retrieve_field_script

  Retrieve a list of fields related with a script (by id).
  On success, data are available through `_sqlite_ans` variable

_Parameters_:

  * `$1`: a list of fields separeted by , to retrieve
  * `$2`: id of the script

_Return_:

  * `0`: on success
  * `1`: on error. (An exit 1 command is call if no data are found)

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_tools.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_retrieve_field_script
    :end-before: dbm__dbm_retrieve_field_script_end
```
#### _dbm_get_table_schema

  Retrieve database schema of the input table of DBRM module.

_Parameters_:

  * `$1`: table name

_Return_:

  * `0`: on success
  * `1`: on error. (An exit 1 command is call on error).

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_tools.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_get_table_schema
    :end-before: dbm__dbm_get_table_schema_end
```
#### _dbm_remove_all_scripts_rel_inhib

  Remove all inhibited scripts from a release.

_Parameters_:

  * `$1`: id of the release

_Return_:

  * `0`: on success
  * `1`: on error. (An exit 1 command is call on error).

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_tools.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_remove_all_scripts_rel_inhib
    :end-before: dbm__dbm_remove_all_scripts_rel_inhib_end
```

#### _dbm_remove_release

  Remove a release

_Parameters_:

  * `$1`: id of the release to remove

_Return_:

  * `0`: on success
  * `1`: on error. (An exit 1 command is call on error).

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_tools.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_remove_release
    :end-before: dbm__dbm_remove_release_end
```

#### _dbm_update_idorder

  Update id order of a list of release of the same branch.

_Parameters_:

  * `$1`: id of the branch

_Return_:

  * `0`: on success
  * `1`: on error. (An exit 1 command is call on error).

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_tools.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_update_idorder
    :end-before: dbm__dbm_update_idorder_end
```
#### _dbm_remove_all_scripts_rel_ded

  Remove all dedicated scripts from a release.

_Parameters_:

  * `$1`: id of the release

_Return_:

  * `0`: on success
  * `1`: on error. (An exit 1 command is call on error).

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_tools.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_remove_all_scripts_rel_ded
    :end-before: dbm__dbm_remove_all_scripts_rel_ded_end
```

#### _dbm_save2undo

  Save input command to undo file.

_Parameters_:

  * `$1`: message to write.

_Return_:

  * `0`: on success
  * `1`: on error.

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_tools.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_save2undo
    :end-before: dbm__dbm_save2undo_end
```

#### _dbm_save2history

  Save input command to history file.

_Parameters_:

  * `$1`: message to write.

_Return_:

  * `0`: on success
  * `1`: on error.

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_tools.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_save2history
    :end-before: dbm__dbm_save2history_end
```

#### _dbm_exts_check_extensions

Check if all extensions/modules are present on table
Extensions. If not insert row with version.
If there a new version of a module call module upgrade function if is present.

_Parameters_:

  * `$1`: string for enable quiet mode (optional).

_Return_:

  * `0`: on success
  * `1`: on error.

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_exts.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_exts_check_extensions
    :end-before: dbm__dbm_exts_check_extensions_end
```

#### _dbm_exts_is_present

Check if an extension is present on Extensions table.
Save extension version to `_ext_version` variable.

_Parameters_:

  * `$1`: Name of the extension.

_Return_:

  * `0`: extension is present
  * `1`: on error or if extension is not present.

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_exts.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_exts_is_present
    :end-before: dbm__dbm_exts_is_present_end
```

#### _dbm_exts_inst_extension

Install a new extension in Extensions table.

_Parameters_:

  * `$1`: Name of the extension.
  * `$2`: Version of the extension.

_Return_:

  * `0`: on success.
  * `1`: on error.

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_exts.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_exts_inst_extension
    :end-before: dbm__dbm_exts_inst_extension_end
```

#### _dbm_exts_update_extension

Update extension row in Extensions table.

_Parameters_:

  * `$1`: Name of the extension.
  * `$2`: Version of the extension.

_Return_:

  * `0`: on success.
  * `1`: on error.

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_exts.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_exts_update_extension
    :end-before: dbm__dbm_exts_update_extension
```

#### _dbm_exts_update_extension

Update extension row in Extensions table.

_Parameters_:

  * `$1`: Name of the extension.
  * `$2`: Version of the extension.

_Return_:

  * `0`: on success.
  * `1`: on error.

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_exts.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_exts_update_extension
    :end-before: dbm__dbm_exts_update_extension
```

#### _dbm_exts_check_dbm

Check if dbm module is upgraded.

_Return_:

  * `0`: if dbm is updated.
  * `1`: on error or an a *dbrm dbm upgrade* is needed

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_exts.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_exts_check_dbm
    :end-before: dbm__dbm_exts_check_dbm_end
```

#### _dbm_initenv_help

Print on stdout help message of command `initenv`

_Return_:

  * `0`: always

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_args.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_initenv_help
    :end-before: dbm__dbm_initenv_help_end
```

#### _dbm_check_initenv_args

Internal function for parse command line arguments related to
`initenv` command.

_Command Arguments_:

  * `--to-current-dir`: Initialize current directory.
  * `--to-dir target`: Initialize target directory.
  * `--enable-profiles`: Enable profiles mode.
  * `--help|-h`: Show help message.

_Variables Used_:

  * `DBM_INIT_CURRDIR`: Set to 1 if --to-current-dir option is used. Default is 0.
  * `DBM_INIT_DIR`: Set with target directory of the --to-dir option.
  * `DBM_INIT_TARGETDIR`: Set to 1 if --to-dir option is used. Default is 0.
  * `DBM_INIT_PROFILES`: Set to 1 if --enable-profiles is present. Default is 0.

_Return_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_exts.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_check_initenv_args
    :end-before: dbm__dbm_check_initenv_args_end
```

#### _dbm_ins_rel_help

Print on stdout help message of command `insert_releas`.

_Return_:

  * `0`: always

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_args.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_ins_rel_help
    :end-before: dbm__dbm_ins_rel_help_end
```

#### _dbm_check_ins_rel_args

Internal function for parse command line arguments related to
`insert_release` command.

_Command Arguments_:

  * `-n RELEASE_NAME`: Name of the release to add.
  * `-d YYYY-MM-DD`: Release date of the release to add.
  * `-v VERSION`: Version of the release to add.
  * `-a ADAPTER`: Adapter used by the release to add (default is oracle).
  * `-o ID_ORDER`: Id order of the release to add.
  * `-b BRANCH_ID`: Id of the branch connected to release to add.
  * `-dir DIRECTORY`: Directory of the release to add.
  * `-h`: Show insert_release command options.

_Variables Used_:

  * `DBM_REL_NAME`: Release name
  * `DBM_REL_DATE`: Release date
  * `DBM_REL_VERSION`: Release version
  * `DBM_REL_ORDER`: Release order id.
  * `DBM_REL_ADAPTER`: Release adapter
  * `DBM_REL_BRANCH`: Release branch id.
  * `DBM_REL_DIR`: Release directory.

_Return_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_exts.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_check_ins_rel_args
    :end-before: dbm__dbm_check_ins_rel_args_end
```

#### _dbm_add_prof_help

Print on stdout help message of `add_profile` command.

_Return_:

  * `0`: always

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_args.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_add_prof_help
    :end-before: dbm__dbm_add_prof_help_end
```

#### _dbm_prof_help

Print on stdout help message of `del_profile`/`set_profile` command.

_Return_:

  * `0`: always

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_args.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_prof_help
    :end-before: dbm__dbm_prof_help_end
```

#### _dbm_check_prof_args

Internal function for parse command line arguments related to
`del_profile` and `set_profile` command.

_Command Arguments_:

  * `--name NAME`: Name of the profile.
  * `--id ID_PROFILE`: Id of the profile
  * `-h`: Show command options.

_Variables Used_:

  * `DBM_PROFILE_BYNAME`: Set to 1 if is set profile id. Default value is 0.
  * `DBM_PROFILE_BYID`: Set to 1 if is set profile name. Default value is 0.
  * `DBM_PROFILE_NAME`: Name of the profile.
  * `DBM_PROFILE_ID`: Id of the profile.

_Return_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_args.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_prof_help
    :end-before: dbm__dbm_prof_help_end
```

#### _dbm_check_add_prof_args

Internal function for parse command line arguments related to `add_profile` command.

_Command Arguments_:

  * `--name NAME`: Name of the profile
  * `--file FILE`: Profile filename
  * `--default`: Set new profile as default/active.
  * `-h`: Show command options.

_Variables Used_:

  * `DBM_PROFILE_DEFAULT`: Set new profile as default (value 1) or not (value 0).
                           Default value is 0.
  * `DBM_PROFILE_FILENAME`: Filename of the profile.
  * `DBM_PROFILE_NAME`: Name of the profile.

_Return_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/dbm/dbm_args.inc
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: dbm__dbm_check_add_prof_args
    :end-before: dbm__dbm_check_add_prof_args_end
```

