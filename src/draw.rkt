;; SHEET MUSIC EDITOR - DRAW ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#lang racket

(require racket/draw)
(require racket/gui)
(require "core.rkt")

;; Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Document size properties
(define page-width-px 850)
(define top-margin-px 100)
(define stave-height-px 40)
(define stave-gap-px 30)
(define row-gap-px 50)
(define bottom-margin-px 100)
(define l-margin-px 20)
(define r-margin-px 20)

;; Essentially dictates how many measures we cram into a line
;;   Using TWELVE to make the code simple for 1, 2, 3, or 4 beat measures
;;   This will prevent awkward formatting
;;   The code will not work for 5, etc, because it does not divide 12
(define beats-per-line 12)

;; How much space to leave for key signature
(define key-sig-padding-px 50)

;; Utilities ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

;; Drawing the staves ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Draw blank staves, including clef, time sig, key, and measures
;; ***RECURSION
(define (draw-blank-staves score dc)
  ;; Internal proc to draw a set of 5 bars
  (define (draw-bars y)
    (define (draw-bars-helper cnt)
      (if (= cnt 0)
          'done
          (begin (send dc
                       draw-line
                       l-margin-px
                       (+ y (* (- cnt 1) (floor (/ stave-height-px 4))))
                       (- page-width-px r-margin-px)
                       (+ y (* (- cnt 1) (floor (/ stave-height-px 4)))))
                 (draw-bars-helper (- cnt 1)))))
    (draw-bars-helper 5))

  ;; Internal proc to draw a set of n staves
  (define (draw-set-of-staves n y)
    (if (= n 0)
        'done
        (begin (draw-bars (+ y (* (- n 1) (+ stave-height-px stave-gap-px))))
               (draw-set-of-staves (- n 1) y))))

  ;; Internal proc to draw the measure bars
  ;; n indicates how many staves
  ;; m indicates how many measures
  (define (draw-measure-bars y n m)
    (define line-height (+ (* n stave-height-px) (* (- n 1) stave-gap-px)))
    (define measure-width (/ (- page-width-px l-margin-px r-margin-px key-sig-padding-px) m))
    (define (draw-measure-bars-helper x cnt)
      (if (= cnt 0)
          'done
          (begin (send dc draw-line x y x (+ y line-height))
                 (draw-measure-bars-helper (+ x measure-width) (- cnt 1)))))
    (begin
      ;; Draw first line
      (send dc draw-line l-margin-px y l-margin-px (+ y line-height))
      ;; Draw the rest of the lines recursively
      (draw-measure-bars-helper (+ l-margin-px key-sig-padding-px measure-width) m)))
  
  ;; Internal proc to draw all staves recursively
  ;; It takes the number of staves
  ;;    and the number of rows of staves in the document
  (define (draw-all-staves n rows time)
    (if (= rows 0)
           'done
           (let ([y (+ top-margin-px
                       (* (- rows 1) n stave-height-px)
                       (* (- rows 1) (- n 1) stave-gap-px)
                       (* (- rows 1) row-gap-px))])
           (begin (draw-set-of-staves n y)
                  (draw-measure-bars y n (/ beats-per-line (get-upper time)))
                  (draw-all-staves n (- rows 1) time)))))
  
  (draw-all-staves (length (get-staves score))
                   (ceiling (/ (count-beats score) beats-per-line))
                   (get-time-sig score)))
    
;; Drawing the notes ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Draw all notes
(define (draw-notes score dc) 'foo)

;; Render the final document ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Render the document
(define (render target)
  (make-object image-snip% target))

;; Main driver ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
    (draw-blank-staves score dc)
    ;; Draw notes onto the staves
    ;; (draw-notes score dc)
    ;; Render the document
    (render drawing)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Experimental Code ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Draw a treble clef on dc at a certain scale s
(define (draw-treble dc s)
  (send dc draw-bitmap
        (make-object bitmap% "../img/small/treble.png" 'png/alpha #f #f s) 0 0))

;; Create & draw an arbitrary score for verification
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
(define my-score (make-score (make-time-sig 4 4)
                             60
                             my-staff-treble
                             my-staff-bass))
(draw my-score)