#lang info

(define pkg-name "openfst-x86_64-macosx")
(define collection "openfst")
(define version "0.0")
(define pkg-desc
  "native libraries for \"openfst\" on \"x86_64-macosx\"")

(define deps
  '("base"))

(define install-platform #rx"mac")
(define copy-foreign-libs
  '())

(define license
  'Apache-2.0)
