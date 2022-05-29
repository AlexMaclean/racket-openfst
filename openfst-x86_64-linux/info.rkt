#lang info

(define pkg-name "openfst-x86_64-linux")
(define collection "openfst")
(define version "0.0")
(define pkg-desc
  "native libraries for \"openfst\" on \"x86_64-linux\"")

(define deps
  '("base"))

(define install-platform #rx"^x86_64-linux(?:-natipkg)?$")
(define copy-foreign-libs
  '("libfst.so.25"
    "openfst_wrapper.so"))

(define license
  'Apache-2.0)
