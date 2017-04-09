#lang racket

(require racket/draw)
(require racket/gui)
(require "core.rkt")

;; Constants
(define page-width-px 850)
(define line-height-px 110)

(define top-margin-px 100)
(define stave-height-px 50)
(define stave-gap-px 20)
(define row-gap-px 50)
(define bottom-margin-px 100)
(define l-margin-px 10)
(define r-margin-px 10)

(define beats-per-line 12)

;; Decides the height of bitmap based on number of lines in the score
(define (decide-height score)
  (let ([num-staves (length (get-staves score))]
        [num-lines (ceiling (/ (count-beats score) beats-per-line))])
    (+ top-margin-px
       (* num-lines (+ (* num-staves stave-height-px)
                       (* (- num-staves 1) stave-gap-px)))
       (* (- num-lines 1) row-gap-px)
       bottom-margin-px)))

;; Draw a border for the document
(define (draw-border w h dc)
  (send dc draw-rectangle 0 0 w h))

;; Draw staves
;; ***RECURSION
(define (draw-staves score dc)
  ;; Internal proc to draw a set of 5 bars
  (define (draw-bars y)
    (define (draw-bars-helper cnt)
      (if (= cnt 0)
          'done
          (begin (send dc
                       draw-line
                       l-margin-px
                       (+ y (* (- cnt 1) (floor (/ stave-height-px 5))))
                       (- page-width-px r-margin-px)
                       (+ y (* (- cnt 1) (floor (/ stave-height-px 5)))))
                 (draw-bars-helper (- cnt 1)))))
    (draw-bars-helper 5))

  ;; Internal proc to draw a set of n staves
  (define (draw-set-of-staves n y)
    (if (= n 0)
        'done
        (begin (draw-bars (+ y (* (- n 1) (+ stave-height-px stave-gap-px))))
               (draw-set-of-staves (- n 1) y))))
  
  ;; Internal proc to draw all staves recursively
  ;; It takes the number of staves
  ;;    and the number of rows of staves in the document
  (define (draw-all-staves n rows)
    (if (= rows 0)
           'done
           (begin (draw-set-of-staves n
                                      (+ top-margin-px
                                         (* (- rows 1) n stave-height-px)
                                         (* (- rows 1) (- n 1) stave-gap-px)
                                         (* (- rows 1) row-gap-px)))
                  (draw-all-staves n (- rows 1)))))
  
  (draw-all-staves (length (get-staves score)) (ceiling (/ (count-beats score) beats-per-line))))
    

;; Render the document
(define (render target)
  (make-object image-snip% target))

;; Draw a treble clef on dc at a certain scale s
(define (draw-treble dc s)
  (send dc draw-bitmap (make-object bitmap% "../img/small/treble.png" 'png/alpha #f #f s) 0 0))

;; Main driver for draw
(define (draw score)
  ;; Local definitions
  (define page-height-px (decide-height score))
  (define drawing (make-bitmap page-width-px page-height-px))
  (define dc (new bitmap-dc% [bitmap drawing]))
  ;;
  (begin
    ;; Draw a border for the document
    (draw-border page-width-px page-height-px dc)
    ;; Draw all the empty staves
    (draw-staves score dc)
    ;; Render the document
    (render drawing)))






;;;;;;;

(define my-staff-treble (make-staff 'treble (make-key-sig C)
                                         (make-note (make-pitch C 4) 2)
                                         (make-note (make-pitch D 4) 2)
                                         (make-note (make-pitch C 4) 2)
                                         (make-note (make-pitch D 4) 2)
                                         (make-note (make-pitch C 4) 2)
                                         (make-note (make-pitch D 4) 2)
                                         (make-note (make-pitch C 4) 4)
                                         (make-note (make-pitch D 4) 4)
                                         (make-note (make-pitch C 4) 4)
                                         (make-note (make-pitch D 4) 1)
                                         (make-note (make-pitch C 4) 1)
                                         (make-note (make-pitch D 4) 2)))
(define my-staff-bass (make-staff 'bass (make-key-sig C)
                                         (make-note (make-pitch C 4) 2)
                                         (make-note (make-pitch D 4) 2)
                                         (make-note (make-pitch C 4) 2)
                                         (make-note (make-pitch D 4) 2)
                                         (make-note (make-pitch C 4) 2)
                                         (make-note (make-pitch D 4) 2)
                                         (make-note (make-pitch C 4) 4)
                                         (make-note (make-pitch D 4) 4)
                                         (make-note (make-pitch C 4) 4)
                                         (make-note (make-pitch D 4) 1)
                                         (make-note (make-pitch C 4) 1)
                                         (make-note (make-pitch D 4) 2)))
(define my-score (make-score (make-time-sig 2 4)
                             60
                             my-staff-treble
                             my-staff-bass))

(draw my-score)