#lang scribble/manual
@require[@for-label[racket/base openfst racket/stream racket/contract]]

@title{OpenFst: Racket Bindings}

@author[(author+email "Alex MacLean" "alex@alex-maclean.com")]

@defmodule[openfst]

This package is definitely a work in progress. Apologies for the current incompleteness!

@section{Abstract Automata Manipulation}

@; [fst-write (fst-like? path-string? . -> . void?)]
@; [rename Fst-Read fst-read (path-string? . -> . fst?)]
@; [fst-cross (fst-like? fst-like? . -> . fst?)]
@; [fst->string (fst-like? . -> . string?)]
@; [fst-shortest-path ((fst-like?) (exact-positive-integer?) . ->* . fst?)]
@; [fst-union   ((fst-like?) #:rest (listof fst-like?) . ->* . fst?)]
@; [fst-compose ((fst-like?) #:rest (listof fst-like?) . ->* . fst?)]
@; [fst-concat  ((fst-like?) #:rest (listof fst-like?) . ->* . fst?)]
@; [fst-accept ((string?) (#:weight real?) . ->* . fst?)]
@; [fst-difference (fst-like? fst-like? . -> . fst?)]
@; [fst-project (fst-like? (or/c 'input 'output) . -> . fst?)]
@; [fst-like (fst-like? . -> . fst?)])

@defproc[(fst? [v any/c]) boolean?]{
 Returns @racket[#true] if the given @racket[v] is a finite-state transducer.
}

@defproc[(fst-like? [v any/c]) boolean?]{
 Returns @racket[(or (string? v) (fst? v))].
}

@defproc[(fst-accept [str string?] [#:weight weight real? 0]) fst?]{

}

@defproc[(fst-cross [fst1 fst-like?] [fst2 fst-like?]) fst?]{

}

@defproc[(fst-difference [fst1 fst-like?] [fst2 fst-like?]) fst?]{

}

@defproc[(fst-union [fst fst-like?] ...+) fst?]{

}

@defproc[(fst-compose [fst fst-like?] ...+) fst?]{

}

@defproc[(fst-concat [fst fst-like?] ...+) fst?]{

}

@defproc[(fst-project [fst fst-like?] [type (or/c 'input 'output)]) fst?]{

}

@defproc[(fst-shortest-path [fst fst-like?] [n exact-positive-integer? 1]) fst?]{

}

@defproc[(fst->string [fst fst-like?]) string?]{

}


@subsection{Derived Utilities}


@;(provide/contract
@; [fst-add-weight (fst-like? real? . -> . fst?)]
@; [fst-insert     ((fst-like?) (#:weight real?) . ->* . fst?)]
@; [fst-delete     ((fst-like?) (#:weight real?) . ->* . fst?)]
@; #;[fst-join       (fst-like? fst-like? . -> . fst?)])

@defproc[(fst-add-weight [fst fst-like?] [weight real?]) fst?]{

}

@defproc[(fst-insert [fst fst-like?] [#:weight weight real? 0]) fst?]{

}

@defproc[(fst-delete [fst fst-like?] [#:weight weight real? 0]) fst?]{

}

@defproc[(fst-join [fst1 fst-like?] [fst2 fst-like?]) fst?]{

}



@section{Direct Automata Access}


@defproc[(make-fst) fst?]{
 Creates a new empty finite state transducer.
}

@defproc[(fst-add-state! [fst fst?]) exact-nonnegative-integer?]{
 Mutate the given @racket[fst] adding a new state and returns that state's id. Genrally states
 start at 0 and increase sequentially, but probably not a good idea to count on this.
}

@defproc[(fst-add-arc! [fst fst?] [state exact-nonnegative-integer?] [arc arc?]) void?]{
 Mutates the given @racket[fst] adding a transition @racket[arc] initiating at @racket[state]. 
}

@defproc[(fst-set-start! [fst fst?] [state exact-nonnegative-integer?]) void?]{
 Mutates the given @racket[fst] re-assigning the start state to the given @racket[state]. The
 provided @racket[state] must already be in the FST. The state that was previously the start
 state will no longer be.
}

@defproc[(fst-set-final! [fst fst?] [state exact-nonnegative-integer?] [weight real?]) void?]{
 Mutates the given @racket[fst], setting the final weight for @racket[state]. This value represents
 the weight that will be added to a path that ends at this state. A value of @racket[+inf.0]
 is the default weight for all states and indicates that a path may not end at this state
 (a non-final state).
}

@defproc[(fst-num-states [fst fst?]) exact-nonnegative-integer?]{
 Returns the total number of states in @racket[fst].
 This is equivalent to @racket[(stream-length (fst-states fst))], though somewhat more efficient.                                            
}

@defproc[(fst-num-arcs [fst fst?] [state exact-nonnegative-integer?]) exact-nonnegative-integer?]{
 Returns the total number of arcs coming from @racket[state] in @racket[fst].
 This is equivalent to @racket[(stream-length (fst-arcs fst state))], though somewhat more efficient.    
}

@defproc[(fst-start [fst fst?]) (or/c #f exact-nonnegative-integer?)]{
 Returns the state id of the start state for the given @racket[fst]. If the FST does not have a
 start state, either because it is empty
 or invalid, returns @racket[#false].
}

@defproc[(fst-final [fst fst?] [state exact-nonnegative-integer?]) real?]{
 Returns the final weight associated with the given state. This represents the weight that will be
 added to a path that ends on this state. Final states will have finite weights while non-final
 states have a weight of @racket[+inf.0].
}

@defproc[(fst-states [fst fst?]) (listof exact-nonnegative-integer?)]{
 Returns a lazy stream of the state ids present in @racket[fst]. 

 Example:
 @racketblock[
 (for/list ([state (fst-states fst)])
   (cons state (fst-final fst state)))
 ]
}

@defproc[(fst-arcs [fst fst?] [state exact-nonnegative-integer?]) (listof arc?)]{
 Returns a lazy stream of the arcs originating from @racket[state] in @racket[fst].

 Example:
 @racketblock[
 (for/list ([arc (fst-arcs fst state)])
   (arc-next-state arc))
 ]
}

@subsection{Transition Arcs}

Arcs representat transitions between states in an finite-state transuducer. Each arc consists of a
in-label, an out-label, a weight and a next state. Arcs are added to the automata at the states
from which they originate.

As an implementation note, arc objects are infact pointers to underlying C++ objects in foreign memory.
From the presective of the user, however they conform to the @racket[struct] interface.

@defproc[(arc? [v any/c]) boolean?]{
 Returns @racket[#true] if the given @racket[v] is a fintite-state transducer arc.
}

@defproc[(arc [ilabel (or/c char? exact-nonnegative-integer?)]
              [olable (or/c char? exact-nonnegative-integer?)] [weight real?]
                                 [next-state exact-nonnegative-integer?]) arc?]{

}

@deftogether[(
             @defproc[(arc-ilabel (arc arc?)) exact-nonnegative-integer?]
             @defproc[(arc-olabel (arc arc?)) exact-nonnegative-integer?]
             @defproc[(arc-weight (arc arc?)) real?]
             @defproc[(arc-next-state (arc arc?)) exact-nonnegative-integer?])
 ]{
}


@; [Arc (label? label? real? exact-nonnegative-integer?  . -> . Arc?)]
@; [Arc-ilabel (Arc? . -> . exact-nonnegative-integer?)]
@; [Arc-olabel (Arc? . -> . exact-nonnegative-integer?)]
@; [Arc-weight (Arc? . -> . real?)]
@; [rename Arc-nextstate Arc-next-state (Arc? . -> . exact-nonnegative-integer?)])

