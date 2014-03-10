#!/bin/bash

. ../modules/out_stdout.mod.in
. ../src/core/commons.sh

DEBUG=true

testStdOut1()
{
    declare -a columns
    declare -a columns2
    declare -a rows

    columns[0]="PROVA1"
    columns[1]="PROVA2"

    columns2[0]="PROVA1B"
    columns2[1]="PROVA2B"

    out_el_pre[0]="\e[1;33m"
    out_el_pre[1]="\e[1;34m"

    out_el_post[0]="\e[m"

    out_rows[0]="columns"
    out_rows[1]="columns2"

    out_tabs[0]="20"
    out_htabs[0]="20"

    out_htabs_mode="tabs"
    #out_htabs_mode="htabs"
    out_prepost_mode="any"

    out_headers[0]="TITLE1"
    out_headers[1]="TITLE2"

    out_stdout_print_arr
}

testStdOut1


# vim: ts=3 sw=3 expandtab
