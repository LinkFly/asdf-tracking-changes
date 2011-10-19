(in-package :asdf) 

(defsystem :test-system
  :defsystem-depends-on (:asdf-tracking-changes)
  :components ((:file "file1")
	       (:file "file2")))
