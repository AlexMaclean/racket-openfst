#lang racket/base

(require ffi/unsafe ffi/unsafe/define ffi/unsafe/define/conventions
         (rename-in racket/contract (-> ->/c)))

(define wrapper-library (ffi-lib "lib/openfst_wrapper"))
(define-ffi-definer define-fst wrapper-library
  #:provide provide-protected
  #:make-c-id convention:hyphen->underscore)

;; Types

(provide/contract
 [FST? (->/c any/c boolean?)]
 [FST-Arc? (->/c any/c boolean?)])

(struct FST (pointer))
(struct FST-Arc (pointer))

(define _Fst (make-ctype (_cpointer 'StdMutableFst) FST-pointer FST))
(define _Arc (make-ctype (_cpointer 'StdArc) FST-Arc-pointer FST-Arc))

(define _SymbolTable_pointer (_cpointer 'SymbolTable))
(define _StringCompiler_pointer (_cpointer 'StringCompiler))
(define _StringPrinter_pointer (_cpointer 'StringPrinter))

(define _StateId _int)

(define _ProjectType (_enum '(PROJECT_INPUT PROJECT_OUTPUT)))

;; Functions

(define-fst new-VectorFst       (_fun -> _Fst))
(define-fst new-VectorFst-copy  (_fun _Fst -> _Fst))
(define-fst VectorFst-AddArc    (_fun _Fst _StateId _Arc -> _void))
(define-fst VectorFst-AddState  (_fun _Fst -> _StateId))
(define-fst VectorFst-AddStates (_fun _Fst _size -> _void))
(define-fst VectorFst-NumStates (_fun _Fst -> _StateId))
(define-fst VectorFst-NumArcs   (_fun _Fst _StateId -> _size))
(define-fst VectorFst-SetStart  (_fun _Fst _StateId -> _void))
(define-fst VectorFst-SetFinal  (_fun _Fst _StateId _float -> _void))

(define-fst Fst-Write     (_fun _Fst _path -> _void))
(define-fst Fst-Final     (_fun _Fst _StateId -> _float))
(define-fst Fst-Start     (_fun _Fst -> _StateId))
(define-fst Fst-Read      (_fun _path -> _Fst))

(define-fst Fst-InputSymbols  (_fun _Fst -> (_or-null _SymbolTable_pointer)))
(define-fst Fst-OutputSymbols (_fun _Fst -> (_or-null _SymbolTable_pointer)))

(define-fst new-Arc (_fun _int _int _float _StateId -> _Arc))

(define-fst SymbolTable-NumSymbols (_fun _SymbolTable_pointer -> _size))
(define-fst SymbolTable-GetNthKey  (_fun _SymbolTable_pointer _size -> _int64))
(define-fst SymbolTable-Find       (_fun _SymbolTable_pointer _int64 -> _string))

(define-fst new-StringCompiler (_fun -> _StringCompiler_pointer))
(define-fst StringCompiler-call (_fun _StringCompiler_pointer _string _float -> _Fst))

(define-fst new-StringPrinter (_fun -> _StringPrinter_pointer))
(define-fst StringPrinter-call (_fun _StringPrinter_pointer _Fst -> _string))

(define-fst Fst-ShortestPath (_fun _Fst _int32 -> _Fst))

(define-fst Fst-Union      (_fun _Fst _Fst -> _Fst))
(define-fst Fst-Compose    (_fun _Fst _Fst -> _Fst))
(define-fst Fst-Cross      (_fun _Fst _Fst -> _Fst))
(define-fst Fst-Concat     (_fun _Fst _Fst -> _Fst))
(define-fst Fst-Difference (_fun _Fst _Fst -> _Fst))

(define-fst Fst-Project (_fun _Fst _ProjectType -> _Fst))
