database-release-manager
========================

Database Release Manager

Documentation:

  Scripts are written with robodoc syntax comments.

Note about Mysql >=5.6:

  From version 5.6 of mysql command line command is present an annoying
  warning message like this
     'Warning: Using a password on the command line interface can be insecure.'
  when is used a --password argument.
  This warning message broken database-release-manager and it is required add
  MYSQL5_6_ENV_PWD="1" on dbrm.conf file.
