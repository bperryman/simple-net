;;;; departures.asd

(asdf:defsystem :simple-net
  :description "Very simple network utils"
  :author "Barry Perryman"
  :license  "BSD 2-Clause"
  :version "0.0.1"
  :serial t
  :depends-on (#+sbcl :sb-bsd-sockets)
  :components ((:file "simple-net")))
