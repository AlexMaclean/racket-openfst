#lang info

(define pkg-name "openfst-x86_64-macosx")
(define collection "openfst")
(define version "0.0")
(define pkg-desc
  "native libraries for \"openfst\" on \"x86_64-macosx\"")

(define deps
  '("base"))

(define install-platform #rx"^x86_64-macosx")
(define copy-foreign-libs
  '("libfst.25.dylib"
    "openfst_wrapper.dylib"))

(define license
  'Apache-2.0)
