#lang racket

(require "core.rkt")

; ***MAP***
; Map procedure that keeps track of index
(define (indexed-map proc lst)
  (define (imap-helper lst result index)
    (if (null? lst)
        result
        (imap-helper (cdr lst) (append result (list (proc (car lst) index))) (+ index 1))))
  (imap-helper lst '() 0))

; ***MAP***
(define (add-note score staff-index note-length note-name)
  (make-score (get-time-sig score)
              (get-tempo score)
              (indexed-map (lambda (s i)
                             (if (equal? staff-index i)
                                 (make-staff (get-clef s)
                                             (get-key-sig s)
                                             (append (get-notes s)
                                                     (list (make-note
                                                            (make-pitch note-name
                                                                        (get-nearest-octave
                                                                         (last (get-notes s))
                                                                         note-name))
                                                            (calculate-duration
                                                             (get-time-sig score)
                                                             note-length)))))
                                 s))
                           (get-staves score))))

(define (pitch-to-midi pitch)
  (+ (get-note pitch) (* (- (get-octave pitch) 1) 12)))

(define (get-nearest-octave previous-note note-name)
  (let ([previous-octave (get-octave (get-pitch previous-note))]
        [base-score (pitch-to-midi (get-pitch previous-note))])
    (let ([same-octave-score (abs (- (pitch-to-midi (make-pitch note-name previous-octave))
                                     base-score))]
          [up-octave-score (abs (- (pitch-to-midi (make-pitch note-name (+ previous-octave 1)))
                                   base-score))]
          [down-octave-score (abs ( - (pitch-to-midi (make-pitch note-name (- previous-octave 1)))
                                      base-score))])
      (cond [(and (< same-octave-score up-octave-score) (< same-octave-score down-octave-score))
             previous-octave]
            [(and (< up-octave-score same-octave-score) (< up-octave-score down-octave-score))
             (+ previous-octave 1)]
            [else (- previous-octave 1)]))))

(define (calculate-duration time-sig note-length)
  (* note-length (get-lower time-sig)))

(define n (make-note (make-pitch C 4) 4))
(define st (make-staff 'Treble (make-key-sig F) (list n n n n n)))
(define sc (make-score (make-time-sig 4 4) 100 (list st st)))