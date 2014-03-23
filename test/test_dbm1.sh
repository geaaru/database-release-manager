#!/bin/bash

#DEBUG=true

dir=`dirname $0`

. $dir/init_test.sh

remove_dbm_db
load_core_scripts
load_modules

testInitDb()
{
  local out=$(dbm_show_releases)
  assertEquals "No releases available." "$out" || return 1

  out="$(dbm_show_scripts)"
  assertEquals "No scripts available." "$out" || return 1

  out="$(dbm_show_rel_dep)"
  assertEquals "No release dependencies available." "$out" || return 1

  out="$(dbm_show_inhibit_scripts)"
  assertEquals "No scripts available." "$out" || return 1

  out="$(dbm_show_rel_ded_scripts)"
  assertEquals "No scripts available." "$out" || return 1

  out="$(dbm_show_branches)"
  local branch="$(echo $out | grep --colour=none master | wc -l )"
  assertEquals 1 $branch || return 1

  return 0
}

testListAdapter()
{
  #out="$(dbm_show_adapters | grep --colour=none mariadb)"
  local out="$(dbm_show_adapters)"

  # mariadb
  local out_mariadb="$(echo $out | grep --colour=none mariadb | wc -l )"
  # sqlite
  local out_sqlite="$(echo $out | grep --colour=none sqlite | wc -l )"
  # oracle
  local out_oracle="$(echo $out | grep --colour=none oracle | wc -l )"

  assertEquals 1 $out_mariadb || return 1
  assertEquals 1 $out_sqlite || return 1
  assertEquals 1 $out_oracle || return 1

  return 0
}

testListScriptTypes()
{

  local out="$(dbm_show_script_types)"

  # foreign_key
  local fk="$(echo $out | grep --colour=none foreign_key | wc -l )"
  # function
  local f="$(echo $out | grep --colour=none function | wc -l )"
  # initial_ddl
  local iddl="$(echo $out | grep --colour=none initial_ddl | wc -l )"
  # insert
  local ins="$(echo $out | grep --colour=none insert | wc -l )"
  # package
  local pkg="$(echo $out | grep --colour=none package | wc -l )"
  # procedure
  local proc="$(echo $out | grep --colour=none procedure | wc -l )"
  # sequence
  local seq="$(echo $out | grep --colour=none sequence | wc -l )"
  # trigger
  local trig="$(echo $out | grep --colour=none trigger | wc -l )"
  # type
  local t="$(echo $out | grep --colour=none type | wc -l )"
  # update_script
  local us="$(echo $out | grep --colour=none update_script | wc -l )"
  # view
  local view="$(echo $out | grep --colour=none view | wc -l )"

  assertEquals 1 $fk || return 1
  assertEquals 1 $f || return 1
  assertEquals 1 $iddl || return 1
  assertEquals 1 $ins || return 1
  assertEquals 1 $pkg || return 1
  assertEquals 1 $proc || return 1
  assertEquals 1 $seq || return 1
  assertEquals 1 $trig || return 1
  assertEquals 1 $t || return 1
  assertEquals 1 $us || return 1
  assertEquals 1 $view || return 1

  return 0
}

testInsertRelease()
{
  local args="-n TEST -v 0.1.0 -a mariadb -b 1"
  local ins_rel="$(dbm_insert_release dbm insert_release $args)"

  assertEquals "Release TEST v. 0.1.0 insert correctly." "$ins_rel" || return 1

  # Check output

  local rr="$(dbm_show_releases)"

  local out="$(echo $rr | grep --colour=none 0.1.0 | wc -l )"

  assertEquals 1 $out || return 1

  return 0
}

. /usr/bin/shunit2

# vim: ts=2 sw=2 expandtab filetype=sh
