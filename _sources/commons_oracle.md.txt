## Commons Oracle API

A list of functions used with `sqlplus` client tool to retrieve data from Oracle Database server.

### API

#### commons_oracle_check_tnsnames

Check and set `TNS_ADMIN` variable.
As first step try to see if exists file tnsnames.ora under `$packagedir`/etc/ directory, if exists use that directory and set TNS_ADMIN.
If doesn't exists then try to see if TNS_ADMIN variable is already set.

_Parameters_:

   * `$1`: (packagedir) Project directory.

_Returns_:

   * `0`: on sucess
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_check_tnsnames
    :end-before: commons_oracle_commons_oracle_check_tnsnames_end
```

#### commons_oracle_check_sqlplus

Check and set `SQLPLUS` variable with path of the
`sqlplus` program.

_Returns_:

   * `0`: on sucess
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_check_sqlplus
    :end-before: commons_oracle_commons_oracle_check_sqlplus_end
```

#### commons_oracle_check_vars

Check if are present mandatary oracle environment variables
and check validity of TNS_ADMIN variable path.

_Variables_:

   * ORACLE_USER
   * ORACLE_PWD
   * ORACLE_SID
   * ORACLE_DIR

_Returns_:

   * `0`: on sucess
   * `1`: on error (exit with value 1)

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_check_vars
    :end-before: commons_oracle_commons_oracle_check_vars_end
```

#### commons_oracle_check_connection

Check that SQLPLUS and sqlplus_auth variables are set
and try to do a connection to database.

_Returns_:

   * `0`: when connection is ok.
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_check_connection
    :end-before: commons_oracle_commons_oracle_check_connection_end
```
#### commons_oracle_shell

Enter on command line shell of Oracle Database server.

_Returns_:

   * `n`: exit value of sqlplus program.
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_shell
    :end-before: commons_oracle_commons_oracle_shell_end
```

#### commons_oracle_download_all_packages

Download all packages to ORACLE_DIR/packages directory.

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_download_all_packages
    :end-before: commons_oracle_commons_oracle_download_all_packages_end
```

#### commons_oracle_download_create_export_packages

Create export_packages_file script used for download all packages.
If script is present and creation date has less of 7200 seconds
then this function do nothing.

TODO:
  * manage download packages script dynamically

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_download_create_export_packages
    :end-before: commons_oracle_commons_oracle_download_create_export_packages_end
```

#### commons_oracle_download_create_export_package

Create export_packages_file script used for download a particular
package.
Create export_packages_file script used for download all packages.
If script is present and creation date has less of 7200 seconds
then this function do nothing.

TODO:
  * manage download package script dynamically

_Parameters_:

   * `$1`: (packagename) Name of the package to insert on export script.

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_download_create_export_package
    :end-before: commons_oracle_commons_oracle_download_create_export_package_end
```

#### commons_oracle_download_package

Download a particular package to ORACLE_DIR/packages directory.

_Parameters_:

   * `$1`: (packagename) Name of the package to download.

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_download_package
    :end-before: commons_oracle_commons_oracle_download_package_end
```
#### commons_oracle_download_all_functions

Download all functions from schema to ORACLE_DIR/functions directory.

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_download_all_functions
    :end-before: commons_oracle_commons_oracle_download_all_functions_end
```

#### commons_oracle_download_create_export_functions

Create export_function_file script used for download all functions.
If script is present and creation date has less of 7200 seconds
then this function do nothing.

TODO:
  * manage download functions script dynamically

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_download_create_export_functions
    :end-before: commons_oracle_commons_oracle_download_create_export_functions_end
```

#### commons_oracle_download_create_export_function

Create export_function_file script used for download a particular
function.
If script is present and creation date has less of 7200 seconds
then this function do nothing.

TODO:
  * manage download function script dynamically

_Parameters_:

   * `$1`: (functionname) Name of the function to insert on export script.

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_download_create_export_function
    :end-before: commons_oracle_commons_oracle_download_create_export_function_end
```

#### commons_oracle_download_function

Download a particular function to ORACLE_DIR/functions directory.

_Parameters_:

   * `$1`: (functionname) Name of the function to download.

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_download_function
    :end-before: commons_oracle_commons_oracle_download_function_end
```

#### commons_oracle_download_all_views

Download all functions from schema to ORACLE_DIR/views directory.

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_download_all_views
    :end-before: commons_oracle_commons_oracle_download_all_views_end
```

#### commons_oracle_download_create_export_views

Create export_views_file script used for download all views.
If script is present and creation date has less of 7200 seconds
then this function do nothing.

TODO:
  * manage download views script dynamically

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_download_create_export_views
    :end-before: commons_oracle_commons_oracle_download_create_export_views_end
```

#### commons_oracle_download_create_export_view

Create export_view_file script used for download a particular
view.
If script is present and creation date has less of 7200 seconds
then this function do nothing.

TODO:
  * manage download view script dynamically

_Parameters_:

   * `$1`: (viewname) Name of the view to insert on export script.

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_download_create_export_view
    :end-before: commons_oracle_commons_oracle_download_create_export_view_end
```

#### commons_oracle_download_view

Download a particular view to ORACLE_DIR/views directory.

_Parameters_:

   * `$1`: (viewname) Name of the view to download.

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_download_view
    :end-before: commons_oracle_commons_oracle_download_view_end
```

#### commons_oracle_download_all_jobs

Download all jobs from schema to ORACLE_DIR/jobs directory.

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_download_all_jobs
    :end-before: commons_oracle_commons_oracle_download_all_jobs_end
```

#### commons_oracle_download_create_export_jobs

Create export_jobs_file script used for download all jobs.
If script is present and creation date has less of 7200 seconds
then this function do nothing.

TODO:
  * manage download jobs script dynamically

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_download_create_export_jobs
    :end-before: commons_oracle_commons_oracle_download_create_export_jobs_end
```

#### commons_oracle_download_job

Download a particular job to ORACLE_DIR/jobs directory.

_Parameters_:

   * `$1`: (jobname) Name of the job to download.

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_download_job
    :end-before: commons_oracle_commons_oracle_download_job_end
```

#### commons_oracle_download_create_export_job

Create export_job_file script used for download a particular
job.
If script is present and creation date has less of 7200 seconds
then this function do nothing.

TODO:
  * manage download job script dynamically

_Parameters_:

   * `$1`: (jobname) Name of the job to insert on export script.

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_download_create_export_job
    :end-before: commons_oracle_commons_oracle_download_create_export_job_end
```

#### commons_oracle_download_all_schedules

Download all schedulers from schema to ORACLE_DIR/schedules directory.

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_download_all_schedules
    :end-before: commons_oracle_commons_oracle_download_all_schedules_end
```

#### commons_oracle_download_create_export_schedules

Create export_schedules_file script used for download all schedules.
If script is present and creation date has less of 7200 seconds
then this function do nothing.

TODO:
  * manage download schedules script dynamically

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_download_create_export_schedules
    :end-before: commons_oracle_commons_oracle_download_create_export_schedules_end
```

#### commons_oracle_download_schedule

Download a particular schedule to ORACLE_DIR/schedules directory.

_Parameters_:

   * `$1`: (schedulename) Name of the schedule to download.

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_download_schedule
    :end-before: commons_oracle_commons_oracle_download_schedule_end
```

#### commons_oracle_download_create_export_schedule

Create export_schedule_file script used for download a particular
schedule.
If script is present and creation date has less of 7200 seconds
then this function do nothing.

TODO:
  * manage download schedule script dynamically

_Parameters_:

   * `$1`: (schedulename) Name of the schedule to insert on export script.

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_download_create_export_schedule
    :end-before: commons_oracle_commons_oracle_download_create_export_schedule_end
```

#### commons_oracle_download_all_triggers

Download all triggers from schema to ORACLE_DIR/triggers directory.

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_download_all_triggers
    :end-before: commons_oracle_commons_oracle_download_all_triggers_end
```

#### commons_oracle_download_create_export_triggers

Create export_trigger_file script used for download all triggers.
If script is present and creation date has less of 7200 seconds
then this function do nothing.

TODO:
  * manage download schedules script dynamically

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_download_create_export_triggers
    :end-before: commons_oracle_commons_oracle_download_create_export_triggers_end
```

#### commons_oracle_download_trigger

Download a particular trigger to ORACLE_DIR/triggers directory.

_Parameters_:

   * `$1`: (triggername) Name of the trigger to download.

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_download_trigger
    :end-before: commons_oracle_commons_oracle_download_trigger_end
```

#### commons_oracle_download_create_export_trigger

Create export_trigger_file script used for download a particular
trigger.
If script is present and creation date has less of 7200 seconds
then this function do nothing.

TODO:
  * manage download trigger script dynamically

_Parameters_:

   * `$1`: (triggername) Name of the trigger to insert on export script.

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_download_create_export_trigger
    :end-before: commons_oracle_commons_oracle_download_create_export_trigger_end
```

#### commons_oracle_compile_file

Compile a file to current oracle schema.

_Parameters_:

   * `$1`: (file) File to compile.
   * `$2`: (msg) message to write on logfile before and after compilation.

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_compile_file
    :end-before: commons_oracle_commons_oracle_compile_file_end
```

#### commons_oracle_compile_all_packages

Compile all packages under ORACLE_DIR/packages directory.

_Parameters_:

   * `$1`: (msg) message to write on logfile before and after compilation.

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_compile_all_packages
    :end-before: commons_oracle_commons_oracle_compile_all_packages_end
```

#### commons_oracle_compile_all_triggers

Compile all triggers under ORACLE_DIR/triggers directory.

_Parameters_:

   * `$1`: (msg) message to write on logfile before and after compilation.

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_compile_all_triggers
    :end-before: commons_oracle_commons_oracle_compile_all_triggers_end
```

#### commons_oracle_compile_all_functions

Compile all functions under ORACLE_DIR/functions directory.

_Parameters_:

   * `$1`: (msg) message to write on logfile before and after compilation.

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_compile_all_functions
    :end-before: commons_oracle_commons_oracle_compile_all_functions_end
```

#### commons_oracle_compile_all_views

Compile all views under ORACLE_DIR/views directory.

_Parameters_:

   * `$1`: (msg) message to write on logfile before and after compilation.

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_compile_all_views
    :end-before: commons_oracle_commons_oracle_compile_all_views_end
```

#### commons_oracle_compile_all_jobs

Compile all jobs under ORACLE_DIR/jobs directory.

_Parameters_:

   * `$1`: (msg) message to write on logfile before and after compilation.

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_compile_all_jobs
    :end-before: commons_oracle_commons_oracle_compile_all_jobs_end
```

#### commons_oracle_compile_all_schedules

Compile all schedules under ORACLE_DIR/schedules directory.

_Parameters_:

   * `$1`: (msg) message to write on logfile before and after compilation.

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_compile_all_jobs
    :end-before: commons_oracle_commons_oracle_compile_all_jobs_end
```

#### commons_oracle_compile_all_from_dir

Compile all files with .sql extension from input directory
It is possible esclude some .sql files through `ORACLE_COMPILE_FILES_EXCLUDED` variable.

_Parameters_:

   * `$1`: (directory) directory where found .sql files to compile
   * `$2`: (msg_head) message header to insert on logfile.
   * `$3`: (msg) message to write on logfile before and after compilation.

_Returns_:

   * `0`: on success
   * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons_oracle.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_oracle_commons_oracle_compile_all_from_dir
    :end-before: commons_oracle_commons_oracle_compile_all_from_dir_end
```


