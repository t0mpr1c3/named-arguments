#lang racket

(provide define lambda #%app)

;; A solution to this stack overflow question:
;; http://stackoverflow.com/q/38674439/5432501

(require syntax/parse/define ; for define-simple-macro
         (only-in racket [define old-define] [lambda old-lambda] [#%app old-#%app])
         (for-syntax syntax/stx)) ; for stx-map
(module+ test
  (require rackunit))

(begin-for-syntax
  ;; identifier->keyword : Identifer -> (Syntaxof Keyword)
  (define (identifier->keyword id)
    (datum->syntax id (string->keyword (symbol->string (syntax-e id))) id id))
  ;; for use in define
  (define-syntax-class arg-spec
    [pattern name:id
             #:with (norm ...) #'(name)]
    [pattern [name:id default-val:expr]
             #:when (equal? #\{ (syntax-property this-syntax 'paren-shape))
             #:with name-kw (identifier->keyword #'name)
             #:with (norm ...) #'(name-kw [name default-val])])
  ;; for use in #%app
  (define-syntax-class arg
    [pattern arg:expr
             #:when (not (equal? #\{ (syntax-property this-syntax 'paren-shape)))
             #:with (norm ...) #'(arg)]
    [pattern [name:id arg:expr]
             #:when (equal? #\{ (syntax-property this-syntax 'paren-shape))
             #:with name-kw (identifier->keyword #'name)
             #:with (norm ...) #'(name-kw arg)]))

(define-syntax-parser define
  [(define x:id val:expr)
   #'(old-define x val)]
  [(define (fn . args) body:expr ...+)
   #'(old-define fn (lambda args body ...))])

(define-syntax-parser lambda
  [(lambda (arg:arg-spec ...) body:expr ...)
   #'(old-lambda (arg.norm ... ...) body ...)])

(define-syntax-parser #%app
  [(app fn arg:arg ...)
   #:fail-when (equal? #\{ (syntax-property this-syntax 'paren-shape))
   "function applications can't use `{`"
   #'(old-#%app fn arg.norm ... ...)])

(module+ test
  ;; using the new define
  (define (greet4 {hi "hello"}  {given "Joe"}  {surname "Smith"})
    ;; have to use old-#%app for this string-append call
    (string-append hi ", " given " " surname))

  ;; these impliticly use the new #%app macro defined above
  (check-equal? (greet4 {surname "Watchman"} {hi "hey"} {given "Robert"})
                "hey, Robert Watchman")
  ;; omitting arguments makes it use the default
  (check-equal? (greet4 {hi "hey"} {given "Robert"})
                "hey, Robert Smith")
  ;; greet4 can be used within a higher-order function:
  (define symbol-greeting (compose string->symbol greet4))
  (check-equal? (symbol-greeting {hi "hey"} {given "Robert"})
                '|hey, Robert Smith|)
  )
