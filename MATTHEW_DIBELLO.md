# Sheet Music Editor

## Matthew DiBello
### April 30, 2017

# Overview
For this project, we created a program that allows a user to write, edit, save/load/export, and play sheet music. It it a basic version of software similar Sibelius, Finale and MuseScore.

Since a sheet music editor can easily contain hundreds of features, we chose to only implement the most basic features in an attempt to create a fully-functional program, but one that can be wrtitten in a matter of weeks.

The implementation of this project utilizes many of the core concepts that we've studied throughout the course.

**Authorship note:** All of the code described here was written by myself.

# Libraries Used
The code uses four libraries:

```
(require racket/draw)
(require racket/gui)
(require rsound)
```

* The ```draw``` library was used to display the sheet music graphically.
* The ```gui``` library was used to provide a ui to the interface for interacting/modifying the data.
* the ```rsound``` library was used to generate an audio representation of the sheet music and play it for the user.

# Key Code Excerpts

## Recursion to Rebuild Lists

The most important concept in the modifying functions is the use of recursion to rebuild lists. In order to mutate the data that internally represents the sheet music, the code I wrote rebuild the data object and then saves the new object as the global-object.

This concpet it used by over a dozen of my modifying functions, but provided below is one example:

```
(define (add-staff score clef key-name)
  (if (< (length (get-staves score)) max-staves)
      (make-score (get-time-sig score)
                  (get-tempo score)
                  (append (get-staves score)
                          (list (make-staff clef
                                            (make-key-sig key-name)
                                            '()))))
```

This procedure adds a new staff to the score, but to do so, it build a new score from scratch, using information such as the previous score and parameters for building the new staff.


## Map and Filter

Because the main data object for storing information about the sheet music was a list, map and filter were essential to being able to recursively rebuild these lists.

Early on in writing the modifying functions, I realized the need for map and filter functions that kept track of the index as they iterated through a list. (I'll explain why that was necessary farther down.) Here's how I implemented indexed-map:

```
(define (indexed-map proc lst)
  (define (imap-helper lst result index)
    (if (null? lst)
        result
        (imap-helper (cdr lst) (append result (list (proc (car lst) index))) (+ index 1))))
  (imap-helper lst '() 0))
```

This implementation is pretty simple, but quite powerful. It's an iterative process (tail-recursive), and it works by passing along an index parameter with each recursive call.

While this may seem like a trivial addition to the built-in Map procedure, it is actually quite useful. Take the following example:

```
(define (change-key-signature score edit-info note-name)
  (make-score (get-time-sig score)
              (get-tempo score)
              (indexed-map (lambda (s i)
                             (if (equal? (get-current-staff edit-info) i)
                                 (make-staff (get-clef s)
                                             (make-key-sig note-name)
                                             (get-notes s))
                                 s))
                           (get-staves score))))
```

This procedure changes the key signature of a staff (or rather builds a new score with one staff modified). In this instance, I am iterating through the staves of the score and want to change the key signature of one of them. Because the only information I have about the staff is its index, indexed-map allows me to write a modifying procedure (the lambda expression above) that only applies itself to the staff of the correct index.

Now on to indexed-filter:

```
(define (indexed-filter pred lst)
  (define (ifilter-helper lst result index)
    (cond [(null? lst)
           result]
          [(pred (car lst) index)
           (ifilter-helper (cdr lst) (append result (list (car lst))) (+ index 1))]
          [else
           (ifilter-helper (cdr lst) result (+ index 1))]))
  (ifilter-helper lst '() 0))
```

The implementation is similar to indexed-map, so I won't dwell on it. Like Map, it uses an iterative process and passes along the index. This procedure is useful in the following case:

```
(define (remove-staff score edit-info)
  (make-score (get-time-sig score)
              (get-tempo score)
              (indexed-filter
               (lambda (s i) (= (get-current-staff edit-info) i))
               (get-staves score))))
```

Here, we don't want to modify a staff of a given index, but rather not include it at all when rebuilding the score. As a result, indexed-filter is found to be quite useful.
