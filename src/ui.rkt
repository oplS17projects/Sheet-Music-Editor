#lang racket/gui

(require "core.rkt")
(require "modify.rkt")
(require "draw.rkt")
(require racket/gui/base)

;; MUTABLE ITEMS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define global-score 'foo)
(set! global-score (make-score (make-time-sig 4 4)
                               120
                               (list (make-staff 'treble (make-key-sig C) (list (make-note (make-pitch R -1) 4)
                                                                                (make-note (make-pitch R -1) 4)
                                                                                (make-note (make-pitch R -1) 4)
                                                                                (make-note (make-pitch R -1) 4))))))
(define global-edit-info 'bar)
(set! global-edit-info (make-edit-info 0 0))

;; HELPER FUNCTIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (string-to-note-name str)
  (cond [(eq? str "Ab") Ab]
        [(eq? str "A") A]
        [(eq? str "Bb") Bb]
        [(eq? str "B") B]
        [(eq? str "Cb") Cb]
        [(eq? str "C") C]
        [(eq? str "C#") C#]
        [(eq? str "Db") Db]
        [(eq? str "D") D]
        [(eq? str "Eb") Eb]
        [(eq? str "E") E]
        [(eq? str "F") F]
        [(eq? str "F#") F#]
        [(eq? str "Gb") Gb]
        [(eq? str "G") G]))

;; LOADING IMAGES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define eighth-note-file (read-bitmap "../img/small/eighth.png"
                                  'png #f #t
                                  #:backing-scale 3.0))
(define eighth-note (make-bitmap 30 50))
(define dc-eig (new bitmap-dc% [bitmap eighth-note]))
(send dc-eig draw-bitmap eighth-note-file 0 0)

(define quarter-note-file (read-bitmap "../img/small/quarter.png"
                                  'png #f #t
                                  #:backing-scale 3.0))
(define quarter-note (make-bitmap 30 50))
(define dc-qua (new bitmap-dc% [bitmap quarter-note]))
(send dc-qua draw-bitmap quarter-note-file 0 0)

(define half-note-file (read-bitmap "../img/small/half.png"
                               'png #f #t
                               #:backing-scale 3.0))
(define half-note (make-bitmap 30 50))
(define dc-hal (new bitmap-dc% [bitmap half-note]))
(send dc-hal draw-bitmap half-note-file 0 0)

(define whole-note-file (read-bitmap "../img/small/whole.png"
                               'png #f #t
                               #:backing-scale 3.0))
(define whole-note (make-bitmap 30 50))
(define dc-who (new bitmap-dc% [bitmap whole-note]))
(send dc-who draw-bitmap whole-note-file 0 0)

(define treble-file (read-bitmap "../img/small/treble.png"
                               'png #f #t
                               #:backing-scale 5.0))
(define treble (make-bitmap 30 50))
(define dc-tre (new bitmap-dc% [bitmap treble]))
(send dc-tre draw-bitmap treble-file 0 0)

(define bass-file (read-bitmap "../img/small/bass.png"
                               'png #f #t
                               #:backing-scale 3.0))
(define bass (make-bitmap 40 50))
(define dc-bas (new bitmap-dc% [bitmap bass]))
(send dc-bas draw-bitmap bass-file 0 0)

(define natural-file (read-bitmap "../img/small/natural.png"
                               'png #f #t
                               #:backing-scale 8.0))
(define natural (make-bitmap 30 50))
(define dc-nat (new bitmap-dc% [bitmap natural]))
(send dc-nat draw-bitmap natural-file 0 0)

(define flat-file (read-bitmap "../img/small/flat.png"
                               'png #f #t
                               #:backing-scale 8.0))
(define flat (make-bitmap 30 50))
(define dc-fla (new bitmap-dc% [bitmap flat]))
(send dc-fla draw-bitmap flat-file 0 0)

(define sharp-file (read-bitmap "../img/small/sharp.png"
                               'png #f #t
                               #:backing-scale 8.0))
(define sharp (make-bitmap 30 50))
(define dc-sha (new bitmap-dc% [bitmap sharp]))
(send dc-sha draw-bitmap sharp-file 0 0)


;; MAIN PANEL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define mother-frame (new frame%
                          [label "Racket Sheet Music Editor - Toolbar"]
                          [width 1000]
                          [height 800]
                          [alignment '(left top)]))

(define daughter-frame (new horizontal-panel%
                   [parent mother-frame]
                   [alignment '(left top)]
                   [style '(auto-vscroll)]))

(define frame (new vertical-panel%
                   [parent daughter-frame]
                   [alignment '(left top)]
                   [style '(auto-vscroll)]))

(define music-canvas (new canvas% [parent daughter-frame]
     [min-width 800]
     [vert-margin 10]
     [horiz-margin 10]
     [style '(vscroll)]
     [paint-callback
      (lambda (canvas dc)
        (draw global-score global-edit-info dc))]))
(send music-canvas set-canvas-background (make-object color% 200 200 200))

;; EDIT-INFO PANEL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define edit-info-panel (new group-box-panel%
                             [parent frame]
                             [label "Navigation"]
                             [horiz-margin 10]
                             [vert-margin 10]
                             [border 10]
                             [alignment '(center top)]))

(define edit-info-instructions
  (string-append "How to move the cursor:\n"
                 "Left one note: LEFT ARROW\n"
                 "Right one note: RIGHT ARROW\n"
                 "Up one staff: PAGE UP\n"
                 "Down one staff: PAGE DOWN"))

(define edit-info-msg (new message% [parent edit-info-panel]
                          [label edit-info-instructions]))


;; NOTES PANEL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define notes-panel (new group-box-panel%
                        [parent frame]
                        [label "Notes"]
                        [alignment '(center top)]
                        [horiz-margin 10]
                        [vert-margin 10]
                        [border 10]))

(define notes-options-panel (new horizontal-panel%
                                 [parent notes-panel]
                                 [horiz-margin 25]
                                 [alignment '(center top)]))

(define pitch-panel (new vertical-panel%
                         [parent notes-options-panel]
                         [alignment '(left top)]))

(define note-name-selector (new choice%
                                [parent pitch-panel]
                                [label "Note Name "]
                                [choices '("A" "B" "C" "D" "E" "F" "G")]
                                [horiz-margin 10]
                                [vert-margin 10]))

(define accidental-selector (new radio-box%
                                 [parent pitch-panel]
                                 [label "Accidental "]
                                 [choices (list natural sharp flat)]))

(define note-lengths-panel (new vertical-panel%
                                [parent notes-options-panel]
                                [alignment '(right top)]))

(define note-length-selector (new radio-box%
                                  [parent note-lengths-panel]
                                  [label "Note Length "]
                                  [choices (list eighth-note quarter-note
                                                 half-note whole-note)]))

(define note-buttons-panel (new horizontal-panel%
                                [parent notes-panel]
                                [alignment '(center bottom)]))

(define insert-note-btn (new button%
                             [parent note-buttons-panel]
                             [label "Insert Note"]
                             [callback (lambda (button event)
                                         (let ([selection
                                                (send accidental-selector get-selection)]
                                               [note-name
                                                (string-to-note-name
                                                 (send note-name-selector
                                                       get-string-selection))]
                                               [note-type
                                                (send note-length-selector get-selection)])
                                           (let ([adjustment
                                                  (if (= selection 2)
                                                      -1
                                                      selection)]
                                                 [note-length
                                                  (expt 2 note-type)])
                                             (add-note sc ei note-length
                                                       (modulo
                                                        (+ note-name adjustment) 12)))))]))

(define change-note-btn (new button%
                             [parent note-buttons-panel]
                             [label "Change Note"]
                             [callback (lambda (button event)
                                         (let ([selection
                                                (send accidental-selector get-selection)]
                                               [note-name
                                                (string-to-note-name
                                                 (send note-name-selector
                                                       get-string-selection))])
                                           (let ([adjustment
                                                  (if (= selection 2)
                                                      -1
                                                      selection)])
                                             (change-note sc ei 'name
                                                          (modulo
                                                           (+ note-name adjustment) 12)))))]))
                                                      

(define delete-note-btn (new button%
                             [parent note-buttons-panel]
                             [label "Delete Note"]
                             [callback (lambda (button event)
                                         (delete-note sc ei))]))


;; STAVES/SCORE PANEL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define staves-score-panel (new group-box-panel%
                                [label "Staves/Score"]
                                [horiz-margin 10]
                                [vert-margin 10]
                                [border 10]
                                [parent frame]
                                [alignment '(center top)]))

(define staves-score-options-panel (new horizontal-panel%
                                        [parent staves-score-panel]
                                        [alignment '(center top)]
                                        [horiz-margin 10]
                                        [vert-margin 10]
                                        [border 10]))

(define clef-panel (new vertical-panel%
                        [parent staves-score-options-panel]
                        [alignment '(center center)]))

(define clef-selector (new radio-box%
                           [parent clef-panel]
                           [label "Clef"]
                           [choices (list treble bass)]))

(define time-sig-panel (new vertical-panel%
                            [parent staves-score-options-panel]
                            [alignment '(right center)]))

(define key-sig-selector (new choice%
                              [parent time-sig-panel]
                              [label "Key Signature "]
                              [choices '("C" "G" "D" "A" "E" "B" "F#" "C#"
                                             "F" "Bb" "Eb" "Ab" "Db" "Gb" "Cb")]))

(define upper-time-sig-selector (new choice%
                                     [parent time-sig-panel]
                                     [label "Time Signature (Upper) "]
                                     [choices '("1" "2" "3" "4")]))

(define lower-time-sig-selector (new choice%
                                     [parent time-sig-panel]
                                     [label "Time Signature (Lower) "]
                                     [choices '("1" "2" "4")]))

(define tempo-slider (new slider%
                                  [parent staves-score-panel]
                                  [label "Tempo (bpm) "]
                                  [min-value 40]
                                  [max-value 360]))

(define staves-score-btns-panel1 (new horizontal-panel%
                                      [parent staves-score-panel]
                                      [alignment '(center top)]))

(define change-time-sig-btn (new button%
                             [parent staves-score-btns-panel1]
                             [label "Change Time Signature"]
                             [callback (lambda (button event)
                                         (let ([upper (string->number
                                                       (send upper-time-sig-selector
                                                             get-string-selection))]
                                               [lower (string->number
                                                       (send lower-time-sig-selector
                                                             get-string-selection))])
                                           (change-time-signature sc upper lower)))]))

(define change-key-sig-btn (new button%
                             [parent staves-score-btns-panel1]
                             [label "Change Key Signature"]
                             [callback (lambda (button event)
                                         (let ([note-name (string-to-note-name
                                                           (send key-sig-selector
                                                                 get-string-selection))])
                                           (change-key-signature sc ei note-name)))]))

(define staves-score-btns-panel2 (new horizontal-panel%
                                      [parent staves-score-panel]
                                      [alignment '(center top)]))

(define change-tempo-btn (new button%
                             [parent staves-score-btns-panel2]
                             [label "Change Tempo"]
                             [callback (lambda (button event)
                                         (change-tempo sc (send tempo-slider get-value)))]))

(define remove-staff-btn (new button%
                             [parent staves-score-btns-panel2]
                             [label "Remove Staff"]
                             [callback (lambda (button event)
                                         (remove-staff sc ei))]))

(define add-staff-btn (new button%
                             [parent staves-score-btns-panel2]
                             [label "Add Staff"]
                             [callback (lambda (button event)
                                         (let ([note-name (string-to-note-name
                                                           (send key-sig-selector
                                                                 get-string-selection))]
                                               [clef (if (= 0 (send clef-selector
                                                                  get-selection))
                                                         'Treble
                                                         'Bass)])
                                           (add-staff sc clef note-name)))]))
                                
                        
;; TRANSPOSITION PANEL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define transposition-panel (new group-box-panel%
                                 [label "Transposition"]
                                 [horiz-margin 10]
                                 [vert-margin 10]
                                 [border 10]
                                 [parent frame]
                                 [alignment '(center top)]))

(define transposition-sub-panel (new vertical-panel%
                                     [parent transposition-panel]
                                     [alignment '(center bottom)]))

(define transposition-slider (new slider%
                                  [parent transposition-sub-panel]
                                  [label "Half-steps"]
                                  [min-value 1]
                                  [max-value 12]))

(define transposition-up-down (new radio-box%
                                   [parent transposition-sub-panel]
                                   [label "Direction of Transposition"]
                                   [choices '("Up" "Down")]))

(define transposition-btn-panel (new horizontal-panel%
                                     [parent transposition-panel]
                                     [alignment '(center bottom)]))

(define transpose-staff-btn (new button%
                                 [parent transposition-btn-panel]
                                 [label "Transpose Staff"]
                                 [callback (lambda (button event)
                                             (let ([shift-amount
                                                    (send transposition-slider get-value)]
                                                   [direction
                                                    (send transposition-up-down
                                                          get-selection)])
                                               (let ([shift
                                                      (cond [(= direction 0) shift-amount]
                                                            [else (* -1 shift-amount)])])
                                                 (transpose-staff sc ei shift))))]))

(define transpose-score-btn (new button%
                                 [parent transposition-btn-panel]
                                 [label "Transpose Score"]
                                 [callback (lambda (button event)
                                             (let ([shift-amount
                                                    (send transposition-slider get-value)]
                                                   [direction
                                                    (send transposition-up-down
                                                          get-selection)])
                                               (let ([shift
                                                      (cond [(= direction 0) shift-amount]
                                                            [else (* -1 shift-amount)])])
                                                 (transpose-score sc shift))))]))


;; I/O ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (save path)
  (call-with-output-file (string-append path ".scr") ;; "SCoRe file extension
    (lambda (output-port)
      (print global-score output-port))))

(define (load path)
  (begin (set! global-score (eval (read (open-input-string (call-with-input-file (string-append path ".scr")
                                                      (lambda (input-port)
                                                        (let loop ((x (read-char input-port)) (mystr ""))
                                                          (if (not (eof-object? x))
                                                              (loop (read-char input-port)(string-append mystr (string x))) mystr ))))))))
         (send music-canvas refresh)
         (set! global-edit-info (make-edit-info 0 0))))

(define (export path)
  (define export-file
    (new pdf-dc%
         [ interactive #f ]
         [ use-paper-bbox #f ]
         [ as-eps #f ]
         [ width (- page-width-px 100) ]
         [ height (decide-height global-score) ]
         [ output (string-append path ".pdf") ]))
  (send export-file start-doc path)
  (send export-file start-page)
  (draw global-score (make-edit-info -1 -1) export-file)
  (send export-file draw-text path (/ page-width-px 2) (/ top-margin-px 2))
  (send export-file end-page)
  (send export-file end-doc))

(send mother-frame show #t)

(provide (all-defined-out))