#lang info

(define pkg-name "OpenFST")
(define collection "openfst")
(define pkg-desc "Racket bindings for OpenFST")
(define version "0.0")

(define scribblings
  '(("scribblings/openfst.scrbl" ())))

(define deps
  '("base"
    ["openfst-x86_64-linux" #:platform #rx"^x86_64-linux(?:-natipkg)?$"]
    ["openfst-x86_64-windows" #:platform #rx"^x86_64-windows(?:-natipkg)?$"]))

(define build-deps
  '("scribble-lib"
    "racket-doc"
    "rackunit-lib"))

(define compile-omit-paths '("test"))

(define license
  'Apache-2.0)