(in-package :cl-user)

(defpackage :asdf-tracking-changes 
  (:use :cl :asdf :tracking-changes)
  (:export #:compile-op #:load-op #:get-provided-packages #:*changes-sandbox*))

(in-package :asdf-tracking-changes)

(defmethod perform :around ((op operation) (comp cl-source-file))
  (with-monitoring (cons (type-of op) comp)
    (call-next-method)))

(defun get-provided-packages (operation component-path)
  (when (typep operation 'operation)
    (setf operation (type-of operation)))
  (get-sandbox-packages-list (cons operation 
				   (find-component nil component-path))))


