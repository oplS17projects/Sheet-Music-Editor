#lang racket

(require "core.rkt")

(define (add-note score staff-index note-length note-name)
  (let [(staff (get-staff score staff-index))]
    (make-score (get-time-sig score)
                (get-tempo score)
                (filter (lambda (s)
                          (if (equal? s (get-staff score staff-index))
                              (make-staff (get-clef s)
                                          (get-key-sig s)
                                          (append (get-notes s)
                                                  (make-note
                                                   (make-pitch note-name
                                                               (get-nearest-octave
                                                                (last (get-notes s))))
                                                   (calculate-duration
                                                    (get-time-sig score)
                                                    note-length))))
                              s))
                        score))))

(define (get-nearest-octave previous-note)
  (get-octave previous-note))

(define (calculate-duration time-sig note-length)
  (* note-length (get-lower time-sig)))

(define n (make-note (make-pitch C 4) 4))
(define st (make-staff 'Treble (make-key-sig F) n n n n n))
(define s (make-score (make-time-sig 4 4) 100 st st))