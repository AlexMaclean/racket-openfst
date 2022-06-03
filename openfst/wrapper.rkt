#lang racket/base

(require ffi/unsafe
         ffi/unsafe/define
         ffi/unsafe/define/conventions
         racket/runtime-path
         racket/struct
         (for-syntax racket/base)
         (rename-in racket/contract (-> ->/c)))

;; Library
;; ----------------------------------------------------------------------------

(define-runtime-path wrapper-path
  '(so "openfst_wrapper" (#f)))

(define wrapper-library
  (ffi-lib wrapper-path))

(define-ffi-definer define-fst wrapper-library
  #:provide provide-protected
  #:make-c-id convention:hyphen->underscore)

;; Types
;; ----------------------------------------------------------------------------

(provide/contract
 [fst? (->/c any/c boolean?)]
 [arc? (->/c any/c boolean?)])

(struct fst (pointer))

(struct arc (pointer)
  #:methods gen:equal+hash
  [(define (equal-proc arc1 arc2 recursive-equal?)
     (and (= (Arc-ilabel arc1) (Arc-ilabel arc2))
          (= (Arc-olabel arc1) (Arc-olabel arc2))
          (> 1e-10 (abs (- (Arc-weight arc1) (Arc-weight arc2))))
          (= (Arc-nextstate arc1) (Arc-nextstate arc2))))

   (define (hash-proc arc recursive-equal-hash)
     (bitwise-xor (Arc-ilabel arc)
                  (arithmetic-shift (Arc-olabel arc) 2)
                  (arithmetic-shift (Arc-weight arc) 4)
                  (arithmetic-shift (Arc-nextstate arc) 6)))

   (define (hash2-proc arc recursive-equal-hash)
     (bitwise-xor (arithmetic-shift (Arc-ilabel arc) 6)
                  (arithmetic-shift (Arc-olabel arc) 4)
                  (arithmetic-shift (Arc-weight arc) 2)
                  (Arc-nextstate arc)))]
  #:methods gen:custom-write
  [(define write-proc
     (make-constructor-style-printer
      (λ (obj) 'arc)
      (λ (obj) (list (Arc-ilabel obj) (Arc-olabel obj) (Arc-weight obj) (Arc-nextstate obj)))))])

(define _Fst (make-ctype (_cpointer 'StdMutableFst) fst-pointer fst))
(define _Arc (make-ctype (_cpointer 'StdArc) arc-pointer arc))

(define _SymbolTable-pointer (_cpointer 'SymbolTable))
(define _StringCompiler-pointer (_cpointer 'StringCompiler))
(define _StringPrinter-pointer (_cpointer 'StringPrinter))

(define _StateIterator-pointer (_cpointer 'StateIterator))
(define _ArcIterator-pointer (_cpointer 'ArcIterator))

(define _StateId _int)

(define _ProjectType (_enum '(PROJECT_INPUT PROJECT_OUTPUT)))

;; Functions
;; ----------------------------------------------------------------------------

(define-fst new-Fst       (_fun -> _Fst))
(define-fst new-Fst-copy  (_fun _Fst -> _Fst))
(define-fst Fst-AddArc    (_fun _Fst _StateId _Arc -> _void))
(define-fst Fst-AddState  (_fun _Fst -> _StateId))
(define-fst Fst-NumStates (_fun _Fst -> _StateId))
(define-fst Fst-NumArcs   (_fun _Fst _StateId -> _size))
(define-fst Fst-SetStart  (_fun _Fst _StateId -> _void))
(define-fst Fst-SetFinal  (_fun _Fst _StateId _float -> _void))

(define-fst Fst-Write     (_fun _Fst _path -> _void))
(define-fst Fst-Final     (_fun _Fst _StateId -> _float))
(define-fst Fst-Start     (_fun _Fst -> _StateId))
(define-fst Fst-Read      (_fun _path -> _Fst))

(define-fst delete-StringCompiler (_fun _StringCompiler-pointer -> _void))
(define-fst new-StringCompiler (_fun -> _StringCompiler-pointer))
(define-fst StringCompiler-call (_fun _StringCompiler-pointer _string _float -> _Fst))

(define-fst delete-StringPrinter (_fun _StringPrinter-pointer -> _void))
(define-fst new-StringPrinter (_fun -> _StringPrinter-pointer))
(define-fst StringPrinter-call (_fun _StringPrinter-pointer _Fst -> _string))

(define-fst Fst-ShortestPath (_fun _Fst _int32 -> _Fst))

(define-fst Fst-Union      (_fun _Fst _Fst -> _Fst))
(define-fst Fst-Compose    (_fun _Fst _Fst -> _Fst))
(define-fst Fst-Cross      (_fun _Fst _Fst -> _Fst))
(define-fst Fst-Concat     (_fun _Fst _Fst -> _Fst))
(define-fst Fst-Difference (_fun _Fst _Fst -> _Fst))

(define-fst Fst-Invert     (_fun _Fst -> _Fst))
(define-fst Fst-Reverse    (_fun _Fst -> _Fst))
(define-fst Fst-Optimize   (_fun _Fst -> _Fst))

(define-fst Fst-Project (_fun _Fst _ProjectType -> _Fst))
(define-fst Fst-Closure (_fun _Fst _int32 _int32 -> _Fst))
(define-fst Fst-Verify  (_fun _Fst -> _bool))

(define-fst delete-Arc (_fun _Arc -> _void))
(define-fst new-Arc (_fun _int _int _float _StateId -> _Arc))
(define-fst Arc-ilabel (_fun _Arc -> _int))
(define-fst Arc-olabel (_fun _Arc -> _int))
(define-fst Arc-weight (_fun _Arc -> _float))
(define-fst Arc-nextstate (_fun _Arc -> _StateId))

(define-fst delete-StateIterator (_fun _StateIterator-pointer -> _void))
(define-fst new-StateIterator (_fun _Fst -> _StateIterator-pointer))
(define-fst StateIterator-Value (_fun _StateIterator-pointer -> _int))
(define-fst StateIterator-Next (_fun _StateIterator-pointer -> _void))
(define-fst StateIterator-Done (_fun _StateIterator-pointer -> _bool))

(define-fst delete-ArcIterator (_fun _ArcIterator-pointer -> _void))
(define-fst new-ArcIterator (_fun _Fst _StateId -> _ArcIterator-pointer))
(define-fst ArcIterator-Value (_fun _ArcIterator-pointer -> _Arc))
(define-fst ArcIterator-Next (_fun _ArcIterator-pointer -> _void))
(define-fst ArcIterator-Done (_fun _ArcIterator-pointer -> _bool))


;; Currently not in use
;; ----------------------------------------------------------------------------

(define-fst Fst-InputSymbols  (_fun _Fst -> (_or-null _SymbolTable-pointer)))
(define-fst Fst-OutputSymbols (_fun _Fst -> (_or-null _SymbolTable-pointer)))

(define-fst SymbolTable-NumSymbols (_fun _SymbolTable-pointer -> _size))
(define-fst SymbolTable-GetNthKey  (_fun _SymbolTable-pointer _size -> _int64))
(define-fst SymbolTable-Find       (_fun _SymbolTable-pointer _int64 -> _string))

