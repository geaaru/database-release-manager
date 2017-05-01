## Commons API

### API

#### assertNot

Check if last command result (passed in input). If result is equal to res_value
param print message to stdout and exit with value 1.

_Parameters_:

  * `$1`: result value of the command
  * `$2`: check if result value is equal to this value. (numeric value)
  * `$3`: message to print if result is not equal to zero

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_assertNot
    :end-before: commons_assertNot_end
```

#### error_handled

Check if last command result. If result is not equal to 0 then
print a message to stdout and exit with value 1.

_Parameters_:

  * `$1`: message to print if result is not equal to zero.

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_error_handled
    :end-before: commons_error_handled_end
```

#### error_generate

Print input message and exit with value 1 if second parameter is not equal to 0.

_Parameters_:

  * `$1`: message to print on stdout.
  * `$2`: optional field to avoid call to exit program if value is equal to 0.

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_error_handled
    :end-before: commons_error_handled_end
```

#### check_var

Check if variable with name in input contains a string or not.

_Parameters_:

  * `$1`: name of the variable to check.

_Returns_:

  * `1`: length of the variable is zero
  * `0`: length of the variable is not zero

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_check_var
    :end-before: commons_check_var_end
```

#### escape_var

Escape content of the variable with input name.

_Parameters_:

  * `$1`: name of the variable to check.

_Returns_:

  * `0`: always

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_escape_var
    :end-before: commons_escape_var_end
```

#### escape2oct_var

Escape content of the variable with input name like escape_var with octets ascii code.

_Parameters_:

  * `$1`: name of the variable to check.

_Returns_:

  * `0`: always

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_escape_var
    :end-before: commons_escape_var_end
```

#### confirmation_question

Use to generate an input question and manage response.

_Parameters_:

  * `$1`: message with question for user.

_Returns_:

  * `0`: if user answer is yes.
  * `1`: if if user answer is no.
  * `2`: if user answer empty.

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_escape2oct_var
    :end-before: commons_escape2oct_var_end
```

#### push_spaces

Push spaces to stdout.

_Parameters_:

  * `$1`: Number of spaces to write.

_Returns_:

  * `0`: always

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_push_spaces
    :end-before: commons_push_spaces_end
```

#### get_space_str

Create a string with input "str" param at begin and N spaces
where N is equal to max_chars - ${#str}

_Parameters_:

  * `$1`: (var_name) Name of variable where save string with spaces.
  * `$2`: (max_chars) Number of max chars of the string with spaces.
  * `$3`: (str) String to insert at begin of save string.
  * `$4`: (pre_spaces) Number of spaces to add before str. (Optional. default 0).

_Returns_:

  * `0`: on success
  * `1`: on error

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_get_spaces_str
    :end-before: commons_get_spaces_str_end
```

#### commons_exists_prog

Check if a program is available on current PATH.

_Parameters_:

  * `$1`: (program) Name of the program.
  * `$2`: (options) Override default (-v) option on check presence. Optional.

_Returns_:

  * `0`: if program exists
  * `1`: if program doesn't exists or invalid input params.

```eval_rst
.. hidden-literalinclude:: ../../src/core/commons.sh
    :label: (Show/Hide)
    :language: bash
    :starthidden: True
    :start-after: commons_commons_exists_prog
    :end-before: commons_commons_exists_prog_end
```

