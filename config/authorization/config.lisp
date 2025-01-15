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

;; Prefixes used in the constraints below (not in the SPARQL queries)
(define-prefixes
  :mu "http://mu.semte.ch/vocabularies/core/"
  :session "http://mu.semte.ch/vocabularies/session/"
  :ext "http://mu.semte.ch/vocabularies/ext/"
  :foaf "http://xmlns.com/foaf/0.1/"
  :sssom "https://w3id.org/sssom/"
  :locn "http://www.w3.org/ns/locn#"
  :dct "http://purl.org/dc/terms/")

(define-graph users ("http://mu.semte.ch/graphs/users")
  ("foaf:Person"
    -> "foaf:name"
    -> "foaf:account"
    -> "dct:created"
    -> "dct:modified")
  ("foaf:OnlineAccount"
    -> "foaf:accountName"
    -> "foaf:accountServiceHomepage"
    -> "dct:created"
    -> "dct:modified"))

(define-graph ticketgang-locaties ("http://locatieslinkeddata.ticketgang-locations.ticketing.acagroup.be")
  ("locn:Address" -> _)
  ("dct:Location" -> _))
(define-graph kunstenpunt-locaties ("http://locatiessparql.kunstenpunt-locaties.professionelekunsten.kunsten.be")
  ("locn:Address" -> _)
  ("dct:Location" -> _))
(define-graph cultuurparticipatie-metadata ("http://metadata.cultuurparticipatie-metadata.vrijetijdsparticipatie.publiq.be")
  ("locn:Address" -> _)
  ("dct:Location" -> _))
(define-graph publiq-uit-locaties ("http://placessparql.publiq-uit-locaties.vrijetijdsparticipatie.publiq.be")
  ("locn:Address" -> _)
  ("dct:Location" -> _))
(define-graph publiq-uit-organisatoren ("http://organisatorensparql.publiq-uit-organisatoren.vrijetijdsparticipatie.publiq.be")
  ("locn:Address" -> _)
  ("dct:Location" -> _))
(define-graph mappings ("http://mu.semte.ch/graphs/entity-mappings")
  ("sssom:Mapping" -> _))
(define-graph manual-mappings ("http://mu.semte.ch/graphs/entity-manual-mappings")
  ("sssom:Mapping" -> _))

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

(grant (read)
  :to-graph (mappings users)
  :for-allowed-group "logged-in")

(grant (read write)
  :to-graph (manual-mappings)
  :for-allowed-group "logged-in")
