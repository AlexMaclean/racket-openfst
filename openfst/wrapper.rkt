#lang racket/base

(require ffi/unsafe ffi/unsafe/define ffi/unsafe/define/conventions setup/collection-search
         (rename-in racket/contract (-> ->/c)))

;; Library
;; ----------------------------------------------------------------------------

(define wrapper-library
  (or
   (collection-search
    '(lib "openfst/lib")
    #:combine
    (λ (_ path)
      (ffi-lib (build-path path "openfst_wrapper")
               #:fail (λ () #f)))
    #:break?
    (λ (x) x))
   (ffi-lib "lib/openfst_wrapper")))

(define-ffi-definer define-fst wrapper-library
  #:provide provide-protected
  #:make-c-id convention:hyphen->underscore)

;; Types
;; ----------------------------------------------------------------------------

(provide/contract
 [FST? (->/c any/c boolean?)]
 [Arc? (->/c any/c boolean?)])

(struct FST (pointer))
(struct Arc (pointer))

(define _Fst (make-ctype (_cpointer 'StdMutableFst) FST-pointer FST))
(define _Arc (make-ctype (_cpointer 'StdArc) Arc-pointer Arc))

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
(define-fst Fst-AddStates (_fun _Fst _size -> _void))
(define-fst Fst-NumStates (_fun _Fst -> _StateId))
(define-fst Fst-NumArcs   (_fun _Fst _StateId -> _size))
(define-fst Fst-SetStart  (_fun _Fst _StateId -> _void))
(define-fst Fst-SetFinal  (_fun _Fst _StateId _float -> _void))

(define-fst Fst-Write     (_fun _Fst _path -> _void))
(define-fst Fst-Final     (_fun _Fst _StateId -> _float))
(define-fst Fst-Start     (_fun _Fst -> _StateId))
(define-fst Fst-Read      (_fun _path -> _Fst))

(define-fst Fst-InputSymbols  (_fun _Fst -> (_or-null _SymbolTable-pointer)))
(define-fst Fst-OutputSymbols (_fun _Fst -> (_or-null _SymbolTable-pointer)))

(define-fst SymbolTable-NumSymbols (_fun _SymbolTable-pointer -> _size))
(define-fst SymbolTable-GetNthKey  (_fun _SymbolTable-pointer _size -> _int64))
(define-fst SymbolTable-Find       (_fun _SymbolTable-pointer _int64 -> _string))

(define-fst new-StringCompiler (_fun -> _StringCompiler-pointer))
(define-fst StringCompiler-call (_fun _StringCompiler-pointer _string _float -> _Fst))

(define-fst new-StringPrinter (_fun -> _StringPrinter-pointer))
(define-fst StringPrinter-call (_fun _StringPrinter-pointer _Fst -> _string))

(define-fst Fst-ShortestPath (_fun _Fst _int32 -> _Fst))

(define-fst Fst-Union      (_fun _Fst _Fst -> _Fst))
(define-fst Fst-Compose    (_fun _Fst _Fst -> _Fst))
(define-fst Fst-Cross      (_fun _Fst _Fst -> _Fst))
(define-fst Fst-Concat     (_fun _Fst _Fst -> _Fst))
(define-fst Fst-Difference (_fun _Fst _Fst -> _Fst))

(define-fst Fst-Project (_fun _Fst _ProjectType -> _Fst))

(define-fst new-Arc (_fun _int _int _float _StateId -> _Arc))
(define-fst Arc-ilabel (_fun _Arc -> _int))
(define-fst Arc-olabel (_fun _Arc -> _int))
(define-fst Arc-weight (_fun _Arc -> _float))
(define-fst Arc-nextstate (_fun _Arc -> _StateId))

(define-fst new-StateIterator (_fun _Fst -> _StateIterator-pointer))
(define-fst StateIterator-Value (_fun _StateIterator-pointer -> _int))
(define-fst StateIterator-Next (_fun _StateIterator-pointer -> _void))
(define-fst StateIterator-Done (_fun _StateIterator-pointer -> _bool))

(define-fst new-ArcIterator (_fun _Fst _StateId -> _ArcIterator-pointer))
(define-fst ArcIterator-Value (_fun _ArcIterator-pointer -> _Arc))
(define-fst ArcIterator-Next (_fun _ArcIterator-pointer -> _void))
(define-fst ArcIterator-Done (_fun _ArcIterator-pointer -> _bool))
