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
