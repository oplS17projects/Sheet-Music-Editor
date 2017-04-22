#lang racket

(require "core.rkt")

; ***MAP***
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
                                                                         (last (get-notes s))))
                                                            (calculate-duration
                                                             (get-time-sig score)
                                                             note-length)))))
                                 s))
                           (get-staves score))))

(define (get-nearest-octave previous-note)
  (get-octave previous-note))

(define (calculate-duration time-sig note-length)
  (* note-length (get-lower time-sig)))

(define n (make-note (make-pitch C 4) 4))
(define st (make-staff 'Treble (make-key-sig F) (list n n n n n)))
(define sc (make-score (make-time-sig 4 4) 100 (list st st)))