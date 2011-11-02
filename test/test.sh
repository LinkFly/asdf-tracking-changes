#!/bin/sh
sbcl --noinform --load test.lisp --eval "(progn (test-asdf-tracking-changes:run-test) (quit))"