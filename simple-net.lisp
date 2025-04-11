;;;; -*- mode: lisp -*-
;;;; simple-net.lisp
;;;; This file contains a number of utility functions that can be used
;;;; for networking applications.
;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; A couple of network tools to read and write net lines.

(defpackage :simple-net
  (:use :cl)
  (:export #:format-net-line
	   #:write-net-line
	   #:read-net-line
	   #:with-open-socket
           #+CCL
           ccl:with-open-socket))

(in-package :simple-net)

#+SBCL
(eval-when (:compile-toplevel :load-toplevel :execute)
  (require :sb-bsd-sockets))

(defun format-net-line (stream fmt &rest args)
  "Write a new net line using the formatting."
  (format stream "~?~c~c" fmt args #\return #\linefeed))

(defun write-net-line (line stream)
  "Write out the string line to the stream, terminating with CRLF."
  (format stream "~a~c~c" line #\return #\linefeed))

;; TODO: Think about improving this one - loop, larger initial line etc
(defun read-net-line (stream &optional (eof-error-p t) eof-value)
  "Read a line of text from stream, lines are terminated with CRLF."
  #+CLISP (read-line stream nil nil)
  #-CLISP (let ((line (make-array 10 :element-type 'character :adjustable t :fill-pointer 0)))
	    (do ((c (read-char stream eof-error-p eof-value) (read-char stream eof-error-p eof-value)))
		((or (null c)
		     (and (char= c #\return)
			  (char= (peek-char nil stream eof-error-p eof-value) #\linefeed)))
		 (progn
		   (read-char stream eof-error-p eof-value)
		   line))
	      (vector-push-extend c line))))

#-CCL
(defmacro with-open-socket ((stream . args) &body body)
  #+CORMANLISP
  (let ((sock (gensym)))
    (destructuring-bind (&key remote-host remote-port) args
      `(with-client-socket (,sock :host ,remote-host
                                  :port ,remote-port)
         (with-socket-stream (,stream ,sock)
           ,@body))))
  #+CLISP
  (destructuring-bind (&key remote-host remote-port) args
    `(with-open-stream (,stream (socket-connect ,remote-port ,remote-host :external-format :unix))
       ,@body))
  #+CMU18D
  (let ((fd (gensym)))
    (destructuring-bind (&key remote-host remote-port) args
      `(let (,fd ,stream)
         (unwind-protect
		      (progn
                (setf ,fd (connect-to-inet-socket ,remote-host
                                                  ,remote-port))
                (setf ,stream (system:make-fd-stream ,fd
                                                     :input t
                                                     :output t))
                ,@body)
           (when ,stream
             (close ,stream))))))
  #+SBCL
  (let ((sock (gensym)))
    (destructuring-bind (&key remote-host remote-port) args
      `(let (,sock ,stream)
         (unwind-protect 
              (progn
                (setf ,sock (make-instance 'sb-bsd-sockets:inet-socket
                                           :type :stream
                                           :protocol :tcp))
                (sb-bsd-sockets:socket-connect ,sock
                                               (car (sb-bsd-sockets:host-ent-addresses (sb-bsd-sockets:get-host-by-name ,remote-host)))
                                               ,remote-port)
                (setf ,stream (sb-bsd-sockets:socket-make-stream ,sock
                                                                 :input t
                                                                 :output t
                                                                 :buffering :none))
                ,@body)
           (progn
             (when ,stream
               (close ,stream))
             (when ,sock
               (sb-bsd-sockets:socket-close ,sock))))))))

