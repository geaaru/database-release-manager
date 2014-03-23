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

testInsertBranch ()
{
  local args="-n 0.3.x"
  local ins_bra="$(dbm_insert_branch dbm insert_branch $args)"

  assertEquals "Branches 0.3.x insert correctly." "$ins_bra" || return 1

  args="-n 0.4.x"
  ins_bra="$(dbm_insert_branch dbm insert_branch $args)"

  assertEquals "Branches 0.4.x insert correctly." "$ins_bra" || return 1

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

  args="-n TEST -v 0.2.0 -a mariadb -b 1"
  ins_rel="$(dbm_insert_release dbm insert_release $args)"

  assertEquals "Release TEST v. 0.2.0 insert correctly." "$ins_rel" || return 1

  args="-n TEST -v 0.3.0 -a mariadb -b 1"
  ins_rel="$(dbm_insert_release dbm insert_release $args)"

  assertEquals "Release TEST v. 0.3.0 insert correctly." "$ins_rel" || return 1

  args="-n TEST -v 0.3.1 -a mariadb -b 2"
  ins_rel="$(dbm_insert_release dbm insert_release $args)"

  assertEquals "Release TEST v. 0.3.1 insert correctly." "$ins_rel" || return 1

  return 0
}

testRemoveRelease ()
{
  local args="-r 1 -f"
  #local rm_rel="$(dbm_remove_release dbm remove_release $args)"
  local res=$?

  dbm_remove_release dbm remove_release -r 1 -f
  assertEquals 0 $res || return 1

  args="-n TEST -v 0.1.0 -a mariadb -b 1"
  local ins_rel=$(eval dbm_insert_release dbm insert_release $args)

  assertEquals "Release TEST v. 0.1.0 insert correctly." "$ins_rel" || return 1

  return 0
}

testMoveRelease ()
{
  local args="-n TEST -v 0.2.1 -a mariadb -b 1"
  local ins_rel="$(dbm_insert_release dbm insert_release $args)"

  # Test move before
  args="-n TEST -r 0.2.1 -b 0.3.0"
  local mv_rel="$(dbm_move_release dbm move_release $args)"

  assertEquals "testMoveRelease: before =>" "Moved correctly TEST v.0.2.1 before v.0.3.0." "$mv_rel" || return 1

  # Test move after
  args="-n TEST -v 0.2.2 -a mariadb -b 1"
  ins_rel="$(dbm_insert_release dbm insert_release $args)"

  args="-n TEST -r 0.2.2 -a 0.2.1"
  mv_rel="$(dbm_move_release dbm move_release $args)"

  assertEquals "testMoveRelease: after =>" "Moved correctly TEST v.0.2.2 after v.0.2.1." "$mv_rel" || return 1

  # Check than it isn't possible move release of different branches.

  args="-n TEST -r 0.2.2 -b 0.3.1"
  mv_rel="$(dbm_move_release dbm move_release $args)"

  assertEquals "testMoveRelease: block different branches =>" \
    "move_release command is not possibile between releases of different branches" "$mv_rel" || return 1

  # Test move before
  args="-n TEST -r 0.1.0 -b 0.2.0"
  local mv_rel=$(eval dbm_move_release dbm move_release $args)

  assertEquals "testMoveRelease: before2 =>" "Moved correctly TEST v.0.1.0 before v.0.2.0." "$mv_rel" || return 1

  return 0
}

testInsertScriptType ()
{
  local args='-c test_script_type -d "Test Script Type"'
  local ins_st=$(eval dbm_insert_script_type dbm insert_script_type $args)

  assertEquals "testInsertScriptType: insert" "Script Type test_script_type insert correctly." "$ins_st" || return 1

  # Check output
  local st="$(dbm_show_script_types)"
  local out="$(echo $st | grep --colour=none test_script_type | wc -l )"

  assertEquals 1 $out || return 1

  return 0
}

testInsertScript ()
{
  dbm_show_releases
}

. /usr/bin/shunit2

# vim: ts=2 sw=2 expandtab filetype=sh
