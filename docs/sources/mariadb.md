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

  * `creation_scripts`: this directory contains initial DDL script for create all
                        tables of the project from zero. This directory could be used
                        at begin of the project for the first release, in the next release
                        is then used *update_scripts* directory that contains script for 
                        upgrade project and trace changes between releasees.
  * `dbrm-profiles`: if profiles are enable contains all configuration files for
                     different environment (dev, test, prod, etc.). This directory could be with
                     a different name and depend of value present of DRM_PROFILES_PATH variable.
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

For permit to normal user of the database to retrieve informations used by `dbrm` it is
required set of this *GRANT*:

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

#### Best Practices

Because `dbrm` manage foreign keys on separated mode, initial DDL script must avoid declaration of
foreign keys inside CREATE TABLE statement, but only PRIMARY KEY.

To simplify this process we can create tables with foreign keys also with external tools and then use
`download` command to create a correct initial DDL or also, create tables only with primary keys and
then use `create` command for create foreign keys.

#### Notes about Events

By design when is compiled a recurrence event on information schema of mysql is register event
with a start date that depends by the compilation time, so there is a limit about `dbrm` can
download this particular events.

So for recurrence events the best choice is create script manually and avoid download or download it
and then manually modify code. For example,
for an event like this (created under *schedulers* directory):

```
  DELIMITER $$
  USE `DB_NAME`$$

  CREATE EVENT
    `eventTest1`
    ON SCHEDULE
    EVERY 2 HOUR
    DISABLE
    DO
      BEGIN
        CALL `function1`(0);
      END
    $$
  DELIMITER ;
```

after compilation is possible show event details with `show` command:

```shell
  $# dbrm mariadb show  --event eventTest1
  ===============================================================================================================
  EVENT: eventTest1
  ===============================================================================================================
  DEFINER:                                   db1@192.168.0.%
  TIME_ZONE:                                 UTC
  EVENT_TYPE:                                RECURRING
  EXECUTE_AT:                                
  INTERVAL_FIELD:                            HOUR
  INTERVAL_VALUE:                            2
  STARTS:                                    2017-05-14 15:35:53
  ENDS:                                      
  STATUS:                                    DISABLED
  ON_COMPLETION:                             NOT PRESERVE
  CREATED:                                   2017-05-14 15:35:53
  LAST_ALTERED:                              2017-05-14 15:35:53
  LAST_EXECUTED:                             

```

but if event is downloaded again under *schedulers* directory event is then like this:

```
  -- $Id$
  DELIMITER $$
  USE `DB_NAME`$$

  CREATE EVENT
    `eventTest1`
    ON SCHEDULE
    EVERY 2 HOUR
    STARTS '2017-05-14 15:35:53'
    DISABLE
    DO
      BEGIN
        CALL `function1`(0);
      END
    $$
  DELIMITER ;
```

As is visible on download is added **STARTS** option and so in this case must be removed manually.
I will add in the near future a command line option to remove automatically **STARTS** on download
if required from user.

##### Event Scheduler

On default MySql/MariaDB configuration event scheduler service is disable as default, so for enable and
start events is required enable *event_scheduler* a runtime (with root user):

```shell
  $# dbrm mariadb shell

  MariaDB [db1]> SET GLOBAL event_scheduler = ON  ;
```

or from my.cnf configuration file.

To check if event_scheduler is enable could be used `show` command:

```shell
  $# dbrm mariadb show  --global-vars --vars-filter "scheduler"
  ===============================================================================================================
  GLOBAL VARIABLES
  ===============================================================================================================
  VARIABLE_NAME       VARIABLE_VALUE      
  ===============================================================================================================
  event_scheduler     OFF
```

On cluster configuration *Event Scheduler* doesn't manage automatically activation on single node, so we
can manage concurrent execution through an application mutex or with activation of *event scheduler*
service only on single node.

### Variables

```eval_rst
  .. list-table::
   :header-rows: 1
   :widths: 10, 20

   * - Variable
     - Description
   * - ``MARIADB_USER``
     - Contains username to use for connection to database.
   * - ``MARIADB_PWD``
     - Contains passwrod to use for connection to database.
   * - ``MARIADB_DB``
     - Contains name of the database to use.
   * - ``MARIADB_DIR``
     - Contains path of the directory used for store all database scripts.
   * - ``MARIADB_EXTRA_OPTIONS``
     - Contains optional extra argument to use with `mysql` client command.
   * - ``MARIADB_ENABLE_COMMENTS``
     - Set to 1 to enable compilation and store of comment inside function/procedures or to 0
       to remove comments from compiled functions/procedures (Option that could be used on production).
   * - ``MYSQL5_6_ENV_PWD``
     - As describe on next chapter this option is needed for Mysql >= 5.6.
   * - ``MARIADB_HOST``
     - Contains host address to use for connection to database.
   * - ``MARIADB_CLIENT``
     - Contains path of `myql` program. If not initialized dbrm try to automatically set
       this variable.
   * - ``MARIADB_TMZ``
     - Contains Timezone to use on database session. Default is UTC.
   * - ``MARIADB_IGNORE_TMZ``
     - Set to 1 when to avoid initialization of Timezone on database connection. Default is 0.
   * - ``MARIADB_COMPILE_FILES_EXCLUDED``
     - Permit to define a list of script that are present on project directory to ignore
       on compilation proecess.
```


### Commands

#### mariadb version

Show version of mariadb module.

```shell
  $# dbrm mariadb version
  Version: 0.1.0
```

#### mariadb test_connection

Test connection to database of the active profile or active configuration.

##### test_connection options:

This options are generic option for handle connection and are avilable on different
commands.

  * `-P MARIADB_PWD`: Override MARIADB_PWD variable of the configuration file.
  * `-U MARIADB_USER`: Override MARIADB_USER with username of the connection.
  * `-H MARIADB_HOST`: Override MARIADB_HOST with host of the database.
  * `-D MARIADB_DIR`: Override MARIADB_DIR directory where save/retrieve
                      script/functions, etc.
  * `--database db`: Override MARIADB_DB variable for database name.
  * `--timezone tmz`: Override MARIADB_TMZ variable for set timezone on connection session.
  * `--conn-options OPTS`: Override MARIADB_EXTRA_OPTIONS variable for enable
                           extra connection options.
  * `--ignore-timezone`: Set MARIADB_IGNORE_TMZ variable to 1 for disable initial
                         timezone settings.


```shell
  $# dbrm mariadb test_connection
  Connected to openstack_neutron with user neutron correctly.
```

#### mariadb initenv

Initialize project directory that use MariaDB adapter.
Normally, after or before this command is used `dbm initenv` command.

##### initenv options:

  * `--to-current-dir`: Initialize current directory [.].
  * `--to-dir TARGET`: Initialize target directory.
  * `--help|-h`: Show help message.

```shell
  $# dbrm mariadb initenv  --to-current-dir 
  Directories created: 10.
  $# ls
  creation_scripts  foreign_keys  functions  indexes  procedures  schedulers  schemas  triggers  update_scripts  views
```

#### mariadb show

Command `show` permit to analyze different elements of the database:

  * `procedures`: Permit to show list of procedures available on database
  * `triggers`: Permit to show list of triggers available on database
  * `functions`: Permit to show list of functions available on database.
  * `views`: Permit to show list of views available on database.
  * `foreign-keys`: Permit to show list of foreign keys available on database.
                    In particular, permit to retrieve foreign key name, column name, table
                    name and referenced column.
  * `tables`: Permit to show list of tables with Engine name, number of rows, length of data,
              charset and creation date.
  * `indexes`: Permit to show list of indexes available on database with table name,
               index type, unique flag, name of the indexes, and keys columns.
  * `events`: Permit to show list of events available on database.
  * `single data table`: Permit to obtain a summary with different table data: list of table columns,
                         list of foreign key of the table, list of foreign keys from other
                         tables to analyzed table and optional show script of create table.
  * `single foreign key data`: detail about a foreign key.
  * `single event details`: show detail about an event
  * `global variables`: Show configured global variables and filter for a particular value.

##### show options:

  * `--procedures`: Show list of procedures name present on database.
  * `--triggers`: Show list of trigger name present on database.
  * `--functions: Show list of functions name present on database.
  * `--views`: Show list of view name present on database.
  * `--foreign-keys`: Show list of foreign keys name present on database.
  * `--tables`: Show list of tables present on database.
  * `--indexes`: Show list of indexes present on database.
  * `--all`: Show list of all procedures, triggers, functions and views present on database.
  * `--events`: Show list of event/scheduler present on database.
  * `--table TABLE_NAME`: Show detail of a table. This option could be repeated.
  * `--fkey FKEY_NAME`: Show detail of a foreign key. This option could be repeated.
  * `--event EVENT_NAME`: Show detail of a event. This option could be repeated.
  * `--table-def`: Show table definition SQL (To use with --table).
  * `--global-vars`: Show global variables of the instance.
  * `--vars-filter FILTER`: Apply filter in LIKE as %FILTER% (To use with --global-vars).

There are many options with `show` command so I propose only few examples here related with
Openstack Juno database.

*Show table details*

```shell
  $# dbrm mariadb show --table vips 
  ===============================================================================================================
  TABLE: vips
  ===============================================================================================================
  COLUMN_NAME         DEFAULT             NULLABLE  TYPE                        KEY       EXTRA              
  ===============================================================================================================
  tenant_id           NULL                YES       VARCHAR(255)                                             
  id                  NULL                NO        VARCHAR(36)                 PRI                          
  status              NULL                NO        VARCHAR(16)                                              
  status_description  NULL                YES       VARCHAR(255)                                             
  name                NULL                YES       VARCHAR(255)                                             
  description         NULL                YES       VARCHAR(255)                                             
  port_id             NULL                YES       VARCHAR(36)                 MUL                          
  protocol_port       NULL                NO        INT(11)                                                  
  protocol            NULL                NO        ENUM('HTTP','HTTPS','TCP')                               
  pool_id             NULL                NO        VARCHAR(36)                 UNI                          
  admin_state_up      NULL                NO        TINYINT(1)                                               
  connection_limit    NULL                YES       INT(11)                                                  

  ===============================================================================================================
  TABLE FOREIGN KEYS
  ===============================================================================================================
  FOREIGN_KEY_NAME         COLUMN_NAME         TABLE_NAME                  REF_COLUMN_NAME  REF_TABLE_NAME   
  ===============================================================================================================
  vips_ibfk_1              port_id             vips                        id               ports           

  ===============================================================================================================
  FOREIGN KEYS VS. TABLE vips
  ===============================================================================================================
  FOREIGN_KEY_NAME              COLUMN_NAME         TABLE_NAME                  REF_COLUMN_NAME  REF_TABLE_NAME
  ===============================================================================================================
  pools_ibfk_1                  vip_id              pools                       id               vips        
  sessionpersistences_ibfk_1    vip_id              sessionpersistences         id               vips        
  vcns_edge_vip_bindings_ibfk_1 vip_id              vcns_edge_vip_bindings      id               vips     

```

*Show database indexes*

```shell
  $# dbrm mariadb show --indexes
  ===============================================================================================================
  INDEXES
  ===============================================================================================================
  TABLE_NAME                 UNIQUE      INDEX_NAME                  KEYS_COLUMNS                      INDEX_TYPE
  ===============================================================================================================
  agents                     1           PRIMARY                     id                                BTREE
  agents                     1           uniq_agents0agent_type0host agent_type,host                   BTREE
  allowedaddresspairs        1           PRIMARY                     port_id,mac_address,ip_address    BTREE
  arista_provisioned_nets    1           PRIMARY                     id                                BTREE
  arista_provisioned_tenants 1           PRIMARY                     id                                BTREE
  arista_provisioned_vms     1           PRIMARY                     id                                BTREE
  brocadenetworks            1           PRIMARY                     id                                BTREE
  brocadeports               0           network_id                  network_id                        BTREE
  brocadeports               1           PRIMARY                     port_id                           BTREE
  cisco_credentials          1           PRIMARY                     credential_name                   BTREE
  cisco_csr_identifier_map   1           PRIMARY                     ipsec_site_conn_id                BTREE
  cisco_hosting_devices      0           cfg_agent_id                cfg_agent_id                      BTREE

  ...
```

*Show database tables*

```shell

  $# dbrm mariadb show --tables
  ===============================================================================================================
  TABLE_NAME               ENGINE     TABLE_ROWS     DATA_LENGTH    CHARSET   CREATE_TIME          UPDATE_TIME
  ===============================================================================================================
  agents                   InnoDB     0              16384          utf8      2015-09-28 09:08:51  NULL
  alembic_version          InnoDB     0              16384          utf8      2015-09-28 09:08:43  NULL
  allowedaddresspairs      InnoDB     0              16384          utf8      2015-09-28 09:08:44  NULL
  ml2_gre_allocations      InnoDB     14508          393216         utf8      2015-09-28 09:08:51  NULL
  ml2_gre_endpoints        InnoDB     0              16384          utf8      2015-09-28 09:08:44  NULL
  ml2_network_segments     InnoDB     0              16384          utf8      2015-09-28 09:08:54  NULL
  ml2_port_bindings        InnoDB     1              16384          utf8      2015-09-28 09:08:52  NULL
  ml2_vlan_allocations     InnoDB     2452           114688         utf8      2015-09-28 09:08:44  NULL

  ...
```

#### mariadb download

Download procedures, trigger, functions, foreign keys, indexes, views, events and database schema from active database.

##### download options:

  * `--all-procedure`: Download all procedures SQL statements from database and save every procedure
                       under *procedures* directory where name of the file is equal to name of the
                       procedure with .sql extension.
  * `--all-triggers`: Download all triggers SQL statements from database and save every
                      trigger under *triggers* directory where name of the file is equal
                      to name of the trigger with .sql extension.
                      User must manage manually conflit name or use auto-naming feature
                      of `dbrm` on creation.
  * `--all-functions`: Download all functions SQL statements from database and save every
                       function under *functions* directory where name of the file is
                       equal to name of the function with .sql extension.
  * `--all-foreign-keys`: Download all foreign keys SQL statements from database and save
                          every foreign key under *foreign_keys* directory where name of
                          the file is equal to <TABLE_NAME>-<FKEY_NAME> with .sql
                          extension.
  * `--all-indexes`: Download all indexes SQL statements from database and save every
                     index creation command under *indexes* directory where name of the
                     file is equal to <TABLE_NAME>-<INDEX_NAME> with .sql extension.

   * `--all-views`: Download all views from database and save every view under *views*
                    directory
   * `--all-events`: Download all events/schedulers.
   * `--all`: Download all (no tables schemas).
   * `--procedure name`: Download a particular procedure.
   * `--trigger name`: Download a particular trigger.
   * `--function name`: Download a particular function.
   * `--view name`: Download a particular view.
   * `--foreign-key name`: Download a particular foreign key.
   * `--event name`: Download a particular event.
   * `--index name`: Download a particular index (Require --index-table)
                     Only one index a time.
   * `--index-table tname`: Name of table of index to download. (To use with --index).
   * `--with-pk-indexes`: Download also primary key indexes.
                           (To use with --all|--index|--all-indexes)
   * `--all-tables`: Download all tables definitions that aren't present on target
                     file. This option could be used with --file.
   * `--table name`: Download schema of a particular table
                     This option could be used with --file.
   * `--file file`: (optional) File where write tables definitions.
                    Default is creation_scripts/initial_ddl.sql
   * `--fk-table tname`: Table name of foreign key to download. To use with --foreign-key.
                         If this param is missing dbrm try to identify table
                         name. If there are more or one fkey with same name
                         then elaboration is blocked.


There are many options with `show` command so I propose only few examples here related
with Openstack Juno database.

*Download all indexes (not primary keys)*

```shell
  $# dbrm mariadb download --all-indexes
  Download index uniq_agents0agent_type0host of table agents (1 of 76).
  Download index network_id of table brocadeports (2 of 76).
  Download index cfg_agent_id of table cisco_hosting_devices (3 of 76).
  Download index management_port_id of table cisco_hosting_devices (4 of 76).
  Download index profile_id of table cisco_n1kv_network_bindings (5 of 76).
  Download index profile_id of table cisco_n1kv_port_bindings (6 of 76).
  Download index profile_id of table cisco_n1kv_vmnetworks (7 of 76).
  Download index hosting_port_id of table cisco_port_mappings (8 of 76).
  Download index logical_port_id of table cisco_port_mappings (9 of 76).
  Download index hosting_device_id of table cisco_router_mappings (10 of 76).
  Download index csnat_gw_port_id of table csnat_l3_agent_bindings (11 of 76).
  Download index l3_agent_id of table csnat_l3_agent_bindings (12 of 76).
  Download index subnet_id of table dnsnameservers (13 of 76).
  Download index mac_address of table dvr_host_macs (14 of 76).
  Download index uidx_portid_optname of table extradhcpopts (15 of 76).
  Download index fixed_port_id of table floatingips (16 of 76).
  Download index floating_port_id of table floatingips (17 of 76).
  Download index router_id of table floatingips (18 of 76).
  Download index l3_agent_id of table ha_router_agent_port_bindings (19 of 76).
  Download index router_id of table ha_router_agent_port_bindings (20 of 76).
  Download index network_id of table ha_router_networks (21 of 76).
  Download index idx_autoinc_vr_id of table ha_router_vrid_allocations (22 of 76).
  Download index subnet_id of table ipallocationpools (23 of 76).
  Download index network_id of table ipallocations (24 of 76).
  Download index port_id of table ipallocations (25 of 76).
  Download index subnet_id of table ipallocations (26 of 76).
  Download index ipsec_site_connection_id of table ipsecpeercidrs (27 of 76).
  Download index ikepolicy_id of table ipsec_site_connections (28 of 76).
  Download index ipsecpolicy_id of table ipsec_site_connections (29 of 76).
  Download index vpnservice_id of table ipsec_site_connections (30 of 76).
  Download index lsn_id of table lsn_port (31 of 76).
  Download index mac_addr of table lsn_port (32 of 76).
  Download index sub_id of table lsn_port (33 of 76).
  Download index uniq_member0pool_id0address0port of table members (34 of 76).
  Download index metering_label_id of table meteringlabelrules (35 of 76).
  Download index network_id of table ml2_brocadeports (36 of 76).
  Download index segment of table ml2_dvr_port_bindings (37 of 76).
  Download index network_id of table ml2_network_segments (38 of 76).
  Download index segment of table ml2_port_bindings (39 of 76).
  Download index network_gateway_id of table networkconnections (40 of 76).
  Download index network_id of table networkconnections (41 of 76).
  Download index dhcp_agent_id of table networkdhcpagentbindings (42 of 76).
  Download index network_gateway_id of table networkgatewaydevicereferences (43 of 76).
  Download index queue_id of table networkqueuemappings (44 of 76).
  Download index router_id of table nuage_net_partition_router_mapping (45 of 76).
  Download index net_partition_id of table nuage_subnet_l2dom_mapping (46 of 76).
  Download index ofc_id of table ofcfiltermappings (47 of 76).
  Download index ofc_id of table ofcnetworkmappings (48 of 76).
  Download index ofc_id of table ofcportmappings (49 of 76).
  Download index ofc_id of table ofcroutermappings (50 of 76).
  Download index ofc_id of table ofctenantmappings (51 of 76).
  Download index uniq_ovs_tunnel_endpoints0id of table ovs_tunnel_endpoints (52 of 76).
  Download index in_port of table packetfilters (53 of 76).
  Download index network_id of table packetfilters (54 of 76).
  Download index agent_id of table poolloadbalanceragentbindings (55 of 76).
  Download index monitor_id of table poolmonitorassociations (56 of 76).
  Download index vip_id of table pools (57 of 76).
  Download index queue_id of table portqueuemappings (58 of 76).
  Download index network_id of table ports (59 of 76).
  Download index resource_id of table providerresourceassociations (60 of 76).
  Download index ix_quotas_tenant_id of table quotas (61 of 76).
  Download index port_id of table routerports (62 of 76).
  Download index router_id of table routerroutes (63 of 76).
  Download index router_id of table routerrules (64 of 76).
  Download index gw_port_id of table routers (65 of 76).
  Download index security_group_id of table securitygroupportbindings (66 of 76).
  Download index remote_group_id of table securitygrouprules (67 of 76).
  Download index security_group_id of table securitygrouprules (68 of 76).
  Download index router_id of table servicerouterbindings (69 of 76).
  Download index subnet_id of table subnetroutes (70 of 76).
  Download index network_id of table subnets (71 of 76).
  Download index network_id of table tunnelkeys (72 of 76).
  Download index pool_id of table vips (73 of 76).
  Download index port_id of table vips (74 of 76).
  Download index router_id of table vpnservices (75 of 76).
  Download index subnet_id of table vpnservices (76 of 76).
  Download operation successfull.

```

