(in-package :mu-cl-resources)

(setf *include-count-in-paginated-responses* t)
(setf *supply-cache-headers-p* t)
(setf sparql:*experimental-no-application-graph-for-sudo-select-queries* t)
(setf *cache-model-properties-p* t)
(setf mu-support::*use-custom-boolean-type-p* nil)
(setq *cache-count-queries-p* t)
(setf sparql:*query-log-types* nil) ;; hint: use app-http-logger for logging queries instead, all is '(:default :update-group :update :query :ask)

(read-domain-file "domain.json")
(read-domain-file "users.json")

(defparameter *import-uknown-literal-datatypes-as-string-p* nil
  "When truethy, treat unknown typed literals as strings in the triplestore.")

(defun import-typed-literal-value-from-sparql-result (type value object)
  "imports a typed-literal-value from a sparql result."
  (let ((import-functor (lhash:gethash type *typed-literal-importers*)))
    (if import-functor
        (funcall (lhash:gethash type *typed-literal-importers*)
                 value object)
        (if  *import-uknown-literal-datatypes-as-string-p*
            value
            (error 'simple-error :format-control "Do not know how to import:~%  - type ~A~%  - from ~A." :format-arguments (list type object))))))

(setf *import-uknown-literal-datatypes-as-string-p* t)
