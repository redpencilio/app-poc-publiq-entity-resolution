;;;;;;;;;;;;;;;;;;;
;;; delta messenger
(in-package :delta-messenger)

(add-delta-logger)
(add-delta-messenger "http://delta-notifier/")

;;;;;;;;;;;;;;;;;
;;; configuration
(in-package :client)
(setf *log-sparql-query-roundtrip* t)
(setf *backend* "http://triplestore:8890/sparql")

(in-package :server)
(setf *log-incoming-requests-p* nil)

;;;;;;;;;;;;;;;;;
;;; access rights
(in-package :acl)

(defparameter *access-specifications* nil
  "All known ACCESS specifications.")

(defparameter *graphs* nil
  "All known GRAPH-SPECIFICATION instances.")

(defparameter *rights* nil
  "All known GRANT instances connecting ACCESS-SPECIFICATION to GRAPH.")

(type-cache::add-type-for-prefix "http://mu.semte.ch/sessions/" "http://mu.semte.ch/vocabularies/session/Session")

(define-graph ticketgang-locaties ("http://locatieslinkeddata.ticketgang-locations.ticketing.acagroup.be")
  (_ -> _))
(define-graph kunstenpunt-locaties ("http://locatiessparql.kunstenpunt-locaties.professionelekunsten.kunsten.be")
  (_ -> _))
(define-graph cultuurparticipatie-metadata ("http://metadata.cultuurparticipatie-metadata.vrijetijdsparticipatie.publiq.be")
  (_ -> _))
(define-graph publiq-uit-locaties ("http://placessparql.publiq-uit-locaties.vrijetijdsparticipatie.publiq.be")
  (_ -> _))
(define-graph publiq-uit-organisatoren ("http://organisatorensparql.publiq-uit-organisatoren.vrijetijdsparticipatie.publiq.be")
  (_ -> _))  

(supply-allowed-group "public")

(supply-allowed-group "logged-in"
  :parameters ()
  :query "PREFIX session: <http://mu.semte.ch/vocabularies/session/>
      SELECT ?account WHERE {
          <SESSION_ID> session:account ?account .
      } LIMIT 1")

(grant (read)
  :to-graph (ticketgang-locaties
             kunstenpunt-locaties
             cultuurparticipatie-metadata 
             publiq-uit-locaties 
             publiq-uit-organisatoren)
  :for-allowed-group "logged-in")