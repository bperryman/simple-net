# simple-net
Very simple networking utilities for common-lisp - probably too simple.

# Installation
Generic pull down into your local projects folder in quicklisp.

# API
All the functions are in the simple-net package.

Functions that use the words "net-line" use a CR+LF line terminator convention.

## format-net-line (stream format &rest args)
Uses format to send the format to stream and appends a CR+LF.

## write-net-line (line stream)
Writes the line out to the stream and appends a CR+LF.

## read-net-line (stream &optional eof-error-p eof-value)
Reads a line of text from stream, where lines are terminated with a CR+LF.
Defaults to error if an attempt is made to read past the end of stream.

## with-open-socket ((stream . args) &body body)
This an implementation of the with-open-socket from CCL lisp.

