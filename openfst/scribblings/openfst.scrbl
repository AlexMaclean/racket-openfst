#lang scribble/manual
@require[@for-label[racket/base openfst racket/stream racket/contract]]

@title{OpenFst: Racket Bindings}

@author[(author+email "Alex MacLean" "alex@alex-maclean.com")]

@defmodule[openfst]

This package is definitely a work in progress. Apologies for the current incompleteness!


@section{Direct Automata Access}


@defproc[(FST? [v any/c]) boolean?]{
    Returns @racket(#true) if the given val is a finite state transducer, constructed with @racket(make-fst).
}

@defproc[(make-fst) FST?]{

}

@defproc[(fst-add-state! [fst FST?]) exact-nonnegative-integer?]{

}

@defproc[(fst-add-arc! [fst FST?] [state exact-nonnegative-integer?] [arc Arc?]) void?]{

}

@defproc[(fst-set-start! [fst FST?] [state exact-nonnegative-integer?]) void?]{

}

@defproc[(fst-set-final! [fst FST?] [state exact-nonnegative-integer?] [weight real?]) void?]{

}

@defproc[(fst-num-states [fst FST?]) exact-nonnegative-integer?]{

}

@defproc[(fst-num-arcs [fst FST?] [state exact-nonnegative-integer?]) exact-nonnegative-integer?]{

}

@defproc[(fst-start [fst FST?]) (or/c #f exact-nonnegative-integer?)]{

}

@defproc[(fst-weight [fst FST?] [state exact-nonnegative-integer?]) real?]{

}

@defproc[(fst-states [fst FST?]) (stream/c exact-nonnegative-integer?)]{

}

@defproc[(fst-arcs [fst FST?] [state exact-nonnegative-integer?]) (stream/c Arc?)]{

}


@defstruct*[Arc ([ilabel label?] [olable label?] [weight real?] [next-state exact-nonnegative-integer?])]

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

