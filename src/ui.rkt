#lang racket/gui

(require "core.rkt")
(require racket/gui/base)

(define frame (new frame%
                   [label "Test"]
                   [width 600]
                   [height 600]))

(define eighth-note (read-bitmap "../img/small/eighth.png"
                                  'png #f #t
                                  #:backing-scale 3.0))

(define quarter-note (read-bitmap "../img/small/quarter.png"
                                  'png #f #t
                                  #:backing-scale 3.0))

(define half-note (read-bitmap "../img/small/half.png"
                               'png #f #t
                               #:backing-scale 3.0))

(define whole-note (read-bitmap "../img/small/whole.png"
                               'png #f #t
                               #:backing-scale 3.0))

(define eighth-rest (read-bitmap "../img/small/eighth_rest.png"
                                  'png #f #t
                                  #:backing-scale 3.0))

(define quarter-rest (read-bitmap "../img/small/quarter_rest.png"
                                  'png #f #t
                                  #:backing-scale 3.0))

(define half-rest (read-bitmap "../img/small/half_rest.png"
                               'png #f #t
                               #:backing-scale 3.0))

(define whole-rest (read-bitmap "../img/small/whole_rest.png"
                               'png #f #t
                               #:backing-scale 3.0))

(define treble (read-bitmap "../img/small/treble.png"
                               'png #f #t
                               #:backing-scale 3.0))

(define bass (read-bitmap "../img/small/bass.png"
                               'png #f #t
                               #:backing-scale 3.0))

(define natural (read-bitmap "../img/small/natural.png"
                               'png #f #t
                               #:backing-scale 3.0))

(define flat (read-bitmap "../img/small/flat.png"
                               'png #f #t
                               #:backing-scale 3.0))

(define sharp (read-bitmap "../img/small/sharp.png"
                               'png #f #t
                               #:backing-scale 3.0))

(define msg (new message% [parent frame]
                          [label "No events so far..."]))

(new button% [parent frame]
             [label quarter-note]
             [callback (lambda (button event)
                         (send msg set-label "Quarter Note"))])


(send frame show #t)