(require :asdf)

(push (make-pathname :defaults *load-pathname* 
		     :directory (butlast (pathname-directory *load-pathname*))
		     :name nil
		     :type nil)
      asdf:*central-registry*)

;;; Try add tracking-changes path
(let ((tracking-changes-path 
       (make-pathname :defaults *load-pathname* 
		      :directory (append (butlast (pathname-directory *load-pathname*) 2)
					 (list "tracking-changes"))
		      :name nil
		      :type nil)))
  (when (truename tracking-changes-path)
    (push tracking-changes-path asdf:*central-registry*)))
    
(asdf:load-system :asdf-tracking-changes)

(defpackage :test-asdf-tracking-changes 
  (:use :cl :asdf :asdf-tracking-changes)
  (:export #:run-test))

(in-package :test-asdf-tracking-changes)

(defun test-asdf-tracking-changes ()
  (load-system :test-system)
  (equal `(,(find-package :test-package1)
	   ,(find-package :test-package2)
	   ,(find-package :test-package1)
	   ,(find-package :test-package2))
	 (let ((src-comp1 (resolve-src-component '("test-system" "file1")))
	       (src-comp2 (resolve-src-component '("test-system" "file2"))))
	   (append
	    (get-provided-packages src-comp1)
	    (get-provided-packages src-comp2)
	    (get-provided-packages (resolve-src-component (component-pathname src-comp1)))
	    (get-provided-packages (resolve-src-component (component-pathname src-comp2)))))))


(defun run-test (&aux res)
  (format t (if (setf res (test-asdf-tracking-changes))
		"~&Test passed~%"
		"~&Test failed~%"))
  res)
