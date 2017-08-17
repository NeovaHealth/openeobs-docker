#!/bin/bash
# Script to set environment variables for Python 2.7

source /opt/rh/python27/enable
export X_SCLS="`scl enable python27 'echo $X_SCLS'`"
