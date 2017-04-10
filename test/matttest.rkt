#lang racket

(require rackunit)
(require "../src/core.rkt")

"Running UNIT TESTS (MATT-CORE). Errors will be shown below (if any):"

(define my-staff (make-staff
                  'Treble
                  (make-key-sig C)
                  (list (make-note (make-pitch C 4) 1)
                        (make-note (make-pitch D 4) 1)
                        (make-note (make-pitch E 4) 1)
                        (make-note (make-pitch F 4) 1)
                        (make-note (make-pitch G 4) 1)
                        (make-note (make-pitch A 4) 1)
                        (make-note (make-pitch B 4) 1)
                        (make-note (make-pitch C 5) 1))))

; Pitches
(test-case
 "Creating a pitch - C4"
 (let ([my-pitch (make-pitch C 4)])
   (begin (check-equal? (get-note my-pitch) C)
          (check-equal? (get-octave my-pitch) 4))))

; Notes
(test-case
 "Creating a note - C4, single beat"
 (let ([my-note (make-note (make-pitch C 4) 1)])
   (begin (check-equal? (get-note (get-pitch my-note)) C)
          (check-equal? (get-octave (get-pitch my-note)) 4)
          (check-equal? (get-pitch my-note) (cons C 4))
          (check-equal? (get-duration my-note) 1))))

; Key Signatures

; Staves
  