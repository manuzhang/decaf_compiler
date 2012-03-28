#!/bin/python
#
# File: test-all.py
# Authors: Leonid Shamis (leonid.shamis@gmail.com)
#          Keith Schwarz (htiek@cs.stanford.edu)
#
# A test harness that automatically runs your compiler on all of the tests
# in the 'samples' directory.  This should help you diagnose errors in your
# compiler and will help you gauge your progress as you're going.  It also
# will help catch any regressions you accidentally introduce later on in
# the project.
#
# That said, this test script is not designed to catch all errors and you
# will need to do your own testing.  Be sure to look over these tests
# carefully and to think over what cases are covered and, more importantly,
# what cases are not.

import os
from subprocess import *

TEST_DIRECTORY = 'samples'

for _, _, files in os.walk(TEST_DIRECTORY):
  for file in files:
    if not (file.endswith('.decaf') or file.endswith('.frag')):
      continue
    refName = os.path.join(TEST_DIRECTORY, '%s.out' % file.split('.')[0])
    testName = os.path.join(TEST_DIRECTORY, file)

    result = Popen('./dcc < ' + testName, shell = True, stderr = STDOUT, stdout = PIPE)
    result = Popen('diff -w - ' + refName, shell = True, stdin = result.stdout, stdout = PIPE)
    print 'Executing test "%s"' % testName
    print ''.join(result.stdout.readlines())
