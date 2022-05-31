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
    ["openfst-x86_64-win32" #:platform #rx"^win32.x86_64"]
    ["openfst-x86_64-macosx" #:platform #rx"^x86_64-macosx"]))

(define build-deps
  '("scribble-lib"
    "racket-doc"
    "rackunit-lib"))

(define compile-omit-paths '("test"))

(define license
  'Apache-2.0)