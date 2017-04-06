#lang racket

(require rackunit)
(require "../src/core.rkt")

; Creating a time signature
(test-case
 "Creating a time signature of 2/4 time"
 (let ([my-time-sig (make-time-sig 2 4)])
   (begin (check-equal? (get-num-beats my-time-sig) 2)
          (check-equal? (get-beat-unit my-time-sig) 4))))