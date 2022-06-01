#lang scribble/manual
@require[@for-label[racket/base openfst racket/stream racket/contract]]

@title{OpenFst: Racket Bindings}

@author[(author+email "Alex MacLean" "alex@alex-maclean.com")]

@defmodule[openfst]

This package is definitely a work in progress. Apologies for the current incompleteness!


@section{Direct Automata Access}


@defproc[(FST? [v any/c]) boolean?]{
 Returns @racket[#true] if the given v is a finite state transducer,
 constructed with @racket[make-fst].
}

@defproc[(make-fst) FST?]{
 Creates a new empty finite state transducer.
}

@defproc[(fst-add-state! [fst FST?]) exact-nonnegative-integer?]{
 Mutate the given @racket[fst] adding a new state and returns that state's id. Genrally states
 start at 0 and increase sequentially, but probably not a good idea to count on this.
}

@defproc[(fst-add-arc! [fst FST?] [state exact-nonnegative-integer?] [arc Arc?]) void?]{
 Mutates the given @racket[fst] adding a transition @racket[arc] initiating at @racket[state]. 
}

@defproc[(fst-set-start! [fst FST?] [state exact-nonnegative-integer?]) void?]{
 Mutates the given @racket[fst] re-assigning the start state to the given @racket[state]. The
 provided @racket[state] must already be in the FST. The state that was previously the start
 state will no longer be.
}

@defproc[(fst-set-final! [fst FST?] [state exact-nonnegative-integer?] [weight real?]) void?]{
 Mutates the given @racket[fst], setting the final weight for @racket[state]. This value represents
 the weight that will be added to a path that ends at this state. A value of @racket[+inf.0]
 is the default weight for all states and indicates that a path may not end at this state
 (a non-final state).
}

@defproc[(fst-num-states [fst FST?]) exact-nonnegative-integer?]{
 Returns the total number of states in @racket[fst].
 This is equivalent to @racket[(stream-length (fst-states fst))], though somewhat more efficient.                                            
}

@defproc[(fst-num-arcs [fst FST?] [state exact-nonnegative-integer?]) exact-nonnegative-integer?]{
 Returns the total number of arcs coming from @racket[state] in @racket[fst].
 This is equivalent to @racket[(stream-length (fst-arcs fst state))], though somewhat more efficient.    
}

@defproc[(fst-start [fst FST?]) (or/c #f exact-nonnegative-integer?)]{
 Returns the state id of the start state for the given @racket[fst]. If the FST does not have a
 start state, either because it is empty
 or invalid, returns @racket[#false].
}

@defproc[(fst-final [fst FST?] [state exact-nonnegative-integer?]) real?]{
 Returns the final weight associated with the given state. This represents the weight that will be
 added to a path that ends on this state. Final states will have finite weights while non-final
 states have a weight of @racket[+inf.0].
}

@defproc[(fst-states [fst FST?]) (stream/c exact-nonnegative-integer?)]{
 Returns a lazy stream of the state ids present in @racket[fst]. It the behavior of this stream
 undefined if new states are added to @racket[fst].

 Example:
 @racketblock[
 (for/list ([state (fst-states fst)])
   (cons state (fst-final fst state)))
 ]
}

@defproc[(fst-arcs [fst FST?] [state exact-nonnegative-integer?]) (stream/c Arc?)]{
 Returns a lazy stream of the arcs originating from @racket[state] in @racket[fst]. It the behavior
 of this stream undefined if new arcs are added to @racket[state] in @racket[fst].

 Example:
 @racketblock[
 (for/list ([arc (fst-arcs fst state)])
   (Arc-next-state arc))
 ]
}


@defstruct*[Arc ([ilabel label?] [olable label?] [weight real?]
                                 [next-state exact-nonnegative-integer?])]

@; [Arc (label? label? real? exact-nonnegative-integer?  . -> . Arc?)]
@; [Arc-ilabel (Arc? . -> . exact-nonnegative-integer?)]
@; [Arc-olabel (Arc? . -> . exact-nonnegative-integer?)]
@; [Arc-weight (Arc? . -> . real?)]
@; [rename Arc-nextstate Arc-next-state (Arc? . -> . exact-nonnegative-integer?)])


@section{Abstract Automata Manipulation}

@; [fst-write (fst-like? path-string? . -> . void?)]
@; [rename Fst-Read fst-read (path-string? . -> . FST?)]
@; [fst-cross (fst-like? fst-like? . -> . FST?)]
@; [fst->string (fst-like? . -> . string?)]
@; [fst-shortest-path ((fst-like?) (exact-positive-integer?) . ->* . FST?)]
@; [fst-union   ((fst-like?) #:rest (listof fst-like?) . ->* . FST?)]
@; [fst-compose ((fst-like?) #:rest (listof fst-like?) . ->* . FST?)]
@; [fst-concat  ((fst-like?) #:rest (listof fst-like?) . ->* . FST?)]
@; [fst-accept ((string?) (#:weight real?) . ->* . FST?)]
@; [fst-difference (fst-like? fst-like? . -> . FST?)]
@; [fst-project (fst-like? (or/c 'input 'output) . -> . FST?)]
@; [fst-like (fst-like? . -> . FST?)])

@defproc[(fst-like? [v any/c]) boolean?]{
 Returns @racket[(or (string? v) (FST? v))].
}

@defproc[(fst-accept [str string?] [#:weight weight real? 0]) FST?]{

}

@defproc[(fst-cross [fst1 fst-like?] [fst2 fst-like?]) FST?]{

}

@defproc[(fst-difference [fst1 fst-like?] [fst2 fst-like?]) FST?]{

}

@defproc[(fst-union [fst fst-like?] ...+) FST?]{

}

@defproc[(fst-compose [fst fst-like?] ...+) FST?]{

}

@defproc[(fst-concat [fst fst-like?] ...+) FST?]{

}

@defproc[(fst-project [fst fst-like?] [type (or/c 'input 'output)]) FST?]{

}

@defproc[(fst-shortest-path [fst fst-like?] [n exact-positive-integer? 1]) FST?]{

}

@defproc[(fst->string [fst fst-like?]) string?]{

}


@section{Derived Utilities}


@;(provide/contract
@; [fst-add-weight (fst-like? real? . -> . FST?)]
@; [fst-insert     ((fst-like?) (#:weight real?) . ->* . FST?)]
@; [fst-delete     ((fst-like?) (#:weight real?) . ->* . FST?)]
@; #;[fst-join       (fst-like? fst-like? . -> . FST?)])

@defproc[(fst-add-weight [fst fst-like?] [weight real?]) FST?]{

}

@defproc[(fst-insert [fst fst-like?] [#:weight weight real? 0]) FST?]{

}

@defproc[(fst-delete [fst fst-like?] [#:weight weight real? 0]) FST?]{

}

@defproc[(fst-join [fst1 fst-like?] [fst2 fst-like?]) FST?]{

}

