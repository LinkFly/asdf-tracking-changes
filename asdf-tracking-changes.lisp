(in-package :cl-user)

(defpackage :asdf-tracking-changes 
  (:use :cl :asdf :tracking-changes)
  (:export #:compile-op #:load-op 
	   #:get-provided-packages-by-operation
	   #:get-provided-packages
	   #:resolve-src-component
	   #:all-tracking-systems
	   #:*changes-sandbox*))

(in-package :asdf-tracking-changes)

(defmethod perform :around ((op operation) (comp cl-source-file))
  (with-monitoring (cons (type-of op) comp)
    (with-monitoring comp
      (call-next-method))))

(defgeneric get-provided-packages-by-operation (operation component)
  (:documentation "Getting the new packages that were created when operation apply to component"))

(defmethod get-provided-packages-by-operation ((operation symbol) (component cl-source-file))
  (get-sandbox-packages-list (cons operation component)))

(defun find-component-by-path (component-path)
  (find-component nil component-path))

(defun map-cl-source-files (component fn)
  (typecase component
    (module (dolist (component (module-components component))
	      (map-cl-source-files component fn)))
    (cl-source-file (funcall fn component)))) 

(defun find-src-component (abs-pathname systems)  
  (dolist (system systems)
    (map-cl-source-files system 
			 (lambda (src-file)
			   (when (equal (pathname abs-pathname) (component-pathname src-file))
			     (return-from find-src-component src-file))))))

(defun all-tracking-systems ()
  (mapcar #'component-system
	  (loop :for key :being :the hash-key in *changes-sandbox*
	     :append (typecase key
		       (cl-source-file (list key))
		       ((cons number (cons string null))
			(rest key))))))

(defun resolve-src-component (src-component-spec &optional systems)
  "Return cl-source-file object. 
Argument src-component-spec must be list or pathname designator. 
Argument systems recomended if src-component-spec is pathname."
  (declare (type (or pathname string cons) src-component-spec)
	   (type (or system string symbol cons) systems))
  (setf systems
	(typecase systems
	  (cons (mapcar #'find-system systems))
	  (null (all-tracking-systems))
	  (atom (list (find-system systems)))))
  (typecase src-component-spec
    ((or pathname string) (find-src-component (pathname src-component-spec) systems))
    (cons (find-component-by-path src-component-spec))))

(defgeneric get-provided-packages (src-component)
  (:documentation "Returned all the packages that were created on compile-op or load-op operations."))

(defmethod get-provided-packages ((src-component cl-source-file))
  (apply #'union (mapcar
		  (lambda (op)
		    (get-provided-packages-by-operation op src-component))
		  '(compile-op load-op))))



