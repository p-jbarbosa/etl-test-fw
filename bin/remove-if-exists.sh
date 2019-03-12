#!/bin/sh

file=$1

if [ -f $file ] ; then
    rm $file
fi