#lang scribble/manual
@require[@for-label[racket/base]]

@title{OpenFst: Racket Bindings}

@author[(author+email "Alex MacLean" "alex@alex-maclean.com")]


@defmodule[openfst]

Package Description Here



@section{Direct Automata Access}


@defproc[(make-fst) FST?]{

}

@defproc[(fst-add-state! [fst FST?]) natural?]{

}

@defproc[(fst-add-states! [fst FST?] [n natural?]) void?]{

}

@defproc[(fst-add-arc! [fst FST?] [state natural?] [arc Arc?]) void?]{

}

@defproc[(fst-set-start! [fst FST?] [state natural?]) void?]{

}

@defproc[(fst-set-final! [fst FST?] [state natural?] [weight real?]) void?]{

}


@defproc[(fst-num-states [fst FST?]) natural?]{

}

@defproc[(fst-num-arcs [fst FST?] [state natural?]) natural?]{

}

@defproc[(fst-start [fst FST?]) natural?]{

}

@defproc[(fst-weight [fst FST?] [state natural?]) real?]{

}



 [rename Fst-InputSymbols fst-input-symbols (FST? . -> . any/c)]
 [rename Fst-OutputSymbols fst-output-symbols (FST? . -> . any/c)]

 [fst-states (FST? . -> . (stream/c natural?))]
 [fst-arcs (FST? natural? . -> . (stream/c Arc?))]

@defstruct[(Arc )]

 [Arc (label? label? real? natural?  . -> . Arc?)]
 [Arc-ilabel (Arc? . -> . natural?)]
 [Arc-olabel (Arc? . -> . natural?)]
 [Arc-weight (Arc? . -> . real?)]
 [rename Arc-nextstate Arc-next-state (Arc? . -> . natural?)])