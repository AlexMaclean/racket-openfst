#lang info

(define pkg-name "openfst-x86_64-windows")
(define collection "openfst")
(define version "0.0")
(define pkg-desc
  "native libraries for \"openfst\" on \"x86_64-windows\"")

(define deps
  '("base"))

(define install-platform #rx"^win32.x86_64")
(define copy-foreign-libs
  '("openfst_wrapper.dll"))

(define license
  'Apache-2.0)
