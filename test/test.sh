#!/bin/sh

# Only compilation
sbcl --noinform --load test.lisp --eval "(progn (test-asdf-tracking-changes:load-test-system) (quit))"

# Run
sbcl --noinform --load test.lisp --eval "(progn (test-asdf-tracking-changes:run-test) (quit))"