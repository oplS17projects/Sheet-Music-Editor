# Sheet Music Editor

**Note for Fred:** Sorry this is so long...I realized upon completing it that it contained way too many code excerpts, and probably an equally-unnecessary amount of analysis. I guess there was just so much cool stuff I wanted to show off :).

## Matthew DiBello
### April 30, 2017

# Overview
For this project, we created a program that allows a user to write, edit, save/load/export, and play sheet music. It it a basic version of software similar to Sibelius, Finale and MuseScore.

Since a sheet music editor can easily contain hundreds of features, we chose to only implement the most basic features in an attempt to create a fully-functional program that could be wrtitten in a matter of weeks.

**Authorship note:** All of the code described here was written by myself unless otherwise noted (in which case it was co-written by me and Doug).


# Libraries Used
The code uses three libraries:

```
(require racket/draw)
(require racket/gui)
(require rsound)
```

* The ```draw``` library was used to display the sheet music graphically.
* The ```gui``` library was used to provide a UI to the interface for interacting with/modifying the data.
* the ```rsound``` library was used to generate an audio representation of the sheet music and play it for the user.


# Key Code Excerpts

The bulk of the powerful code that I wrote for this project lies in the modifying functions (see src/modify.rkt). Even though I also wrote __Play__ (src/play.rkt) and __UI__ (src/ui.rkt), and co-wrote __Core__ with Doug (src/core.rkt), the majority of the code below is from __Modify__. The procedures in __Modify__ best utilized the core concepts that we studied in this course.


## Initialization Using a Global Object

There are two global objects which contain all the sheet music data. (All the code in this section was co-written by me and Doug). The first object holds all the information about the score. It's initialized as such:

```
(set! global-score (make-score (make-time-sig 4 4)
                               120
                               (list (make-staff 'treble (make-key-sig C) (list (make-note (make-pitch R -1) 0.5))))))
```

A score is composed of a time signature, a tempo, and a list of staves. A staff is composed of a clef, a key signature, and a list of notes. A note is composed of a pitch (a note-value/note-name and an octave) and a duration. All of this information is stored in a list.

The other global object stored information about the user's current editing staff (ie. what staff and note they have selected).

```
(set! global-edit-info (make-edit-info 0 0))
```

These objects are important because they hold all the data necessary for the main modules to operate.

As you may have noticed in the global score code above, there are constructors for many of the "atoms" of our musical data. One example of this is the following:

```
(define (make-score time-sig tempo staves)
  (list time-sig tempo staves))
```

This allows for the simple creation of a score given the correct parameters. Other constructors exist for other musical "atoms".


## Procedural Abstraction (Selectors)

Quite a number of procedures were created us to easily access certain information about the global object or other "atoms" of our musical data. These belong to the __Core__ module, and were co-written by Doug and me.

Just like there were contructors (as described in the above section), there are also selectors which access parts of the object created by the constructor. Here's an example of a contructor and its selectors:

```
(define (make-score time-sig tempo staves)
  (list time-sig tempo staves))

(define get-time-sig car)
(define get-tempo cadr)
(define get-staves caddr)
(define (get-staff score index)
  (define (get-staff-helper staves index)
    (if (> index 0)
        (get-staff-helper (cdr staves) (- index 1))
        (car staves)))
  (get-staff-helper (get-staves score) index))
```

As you can see, most of the selectors are very simple. However, there are some that are more complex, such as get-staff above, which uses recursion (see below).


## Recursion to Rebuild Lists

The most important concept in the modifying functions is the use of recursion to rebuild lists. In order to mutate the data that internally represents the sheet music, the code I wrote rebuilds the data object and then saves the new object as the global-object.

This concept is used by over a dozen of my modifying functions, but provided below is one example:

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

This procedure changes the key signature of a staff (or rather builds a new score with one staff's key signature modified). In this instance, I am iterating through the staves of the score and want to change the key signature of one of them. Because the only information I have about the staff is its index, indexed-map allows me to write a modifying procedure (the lambda expression above) that only applies itself to the staff of the correct index.

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


## Message Passing

In the modifying functions, there was one instance where I wanted a single function to perform two different tasks based on context. Here's the function:

```
(define (change-note score edit-info type modification)
  (cond [(eq? type 'shift)
         (let ([shift modification])
           (modify-note score
                        edit-info
                        (lambda (n) (shift-note n shift))))]
        [(eq? type 'name)
         (let ([note-name modification])
           (modify-note score
                        edit-info
                        (lambda (n)
                          (make-note
                           (make-pitch note-name
                                       (get-nearest-octave
                                        n
                                        note-name))
                           (get-duration n)))))]))  
```

In this function is provided two different ways to change a note. Either the note is shifted a certain number of half steps up or down, or a new note-name is provided. Instead of writing and calling two different functions, I simply allowed this function to take a message parameter (called type). If the type is 'shift, then we assume that the modification parameter is a number of half steps. Else, if the type is 'name, and we assume that the modification parameter is a name. Each message calls a different function with different parameters.


## Procedural Abstraction (Complex Functions)

In the modifying functions, there were several complex functions. Whenever I saw code that I was repeating, I tried to abstract it out into its own function. 

In the code example provided in the previous section (message passing), we see that the function ```modify-note``` is called twice. This is one example of procedural abstraction. I found myself repeating a lot of code for modifying a given note, so I abstracted the procedure out. Let's take a look:

```
(define (modify-note score edit-info proc)
  (modify-notes score
                (get-current-staff edit-info)
                (lambda (notes)
                  (indexed-map (lambda (n i)
                                 (if (= i (get-current-index edit-info))
                                     (proc n)
                                     n))
                               notes))))
```

The only thing that this function does is call another function! This function is called ```modify-notes``` (notice the plural "notes"). This is *another* function that I was able to abstract out, and it is specfically for modifying all the notes of a staff. If we take a look at that procedure, we'll see:

```
(define (modify-notes score staff-index proc)
  (make-score (get-time-sig score)
              (get-tempo score)
              (indexed-map (lambda (s i)
                             (if (equal? staff-index i)
                                 (make-staff (get-clef s)
                                             (get-key-sig s)
                                             (proc (get-notes s)))
                                 s))
                           (get-staves score))))
```

All ```modify-notes``` turns out to be is a call to ```indexed-map```! This makes sense, because in modifying a series of notes, the map function is quite useful.

Now, to see how this fits together, let's take a look at the ```modify-note``` (singular) procedure above. When calling ```modify-notes``` (plural), we provides a procedure that maps through a list of notes and only applies the procedure we've provided if the index of the given note matches the index of the cursor (which is stored in the edit-info we pass in). But to get this list of notes to map through and check, we first need to map through the staves of the score and find the staff with the correct index. That's where ```modify-notes``` (plural) comes in. It looks through the staves until it finds the right one, then it applies the ```indexed-map``` procedure passed along from ```modify-note```.

If these procedures fit together so well, why have we separated them? Well, there are some instances when we want to operate on a series of notes. Take the following procedure for example:

```
(define (transpose-staff score edit-info shift)
  (modify-notes score
                (get-current-staff edit-info)
                (lambda (notes) (map (lambda (n) (shift-note n shift)) notes))))
```

This procedure modifies all the notes in a given staff, so a simple call to ```modify-notes``` will do the trick.
