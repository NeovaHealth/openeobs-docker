# -*- coding: utf-8 -*-
from invoke import task

@task
def something():
    print "something"

@task
def another_thing(a, b, c, kwarg="default value"):
    print "another_thing a=%s, b=%s, c=%s, arg=%s" % (a, b, c, kwarg)

