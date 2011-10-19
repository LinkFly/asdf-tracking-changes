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
  (:export #:run-test #:load-test-system))

(in-package :test-asdf-tracking-changes)

(defun load-test-system () (load-system :test-system))

(defun test-asdf-tracking-changes ()
  (load-system :test-system)
;  (break)
  (equal `((,(find-package :test-package1))
	   (,(find-package :test-package2)))
	 (list 
	  (get-provided-packages 'load-op '("test-system" "file1"))
	  (get-provided-packages 'load-op '("test-system" "file2")))))

(defun run-test (&aux res)
  (format t (if (setf res (test-asdf-tracking-changes))
		"~&Test passed~%"
		"~&Test failed~%"))
  res)

   
