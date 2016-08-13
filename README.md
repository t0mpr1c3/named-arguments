named-arguments [![Build Status](https://travis-ci.org/AlexKnauth/named-arguments.png?branch=master)](https://travis-ci.org/AlexKnauth/named-arguments)
===
A different syntax for specifying named arguments in Racket

```racket
> (require named-arguments/square-brackets)
> (define (kinetic-energy [mass 0] [speed 0])
    (* 1/2 mass (* speed speed)))
> (kinetic-energy [mass 1] [speed 1])
1/2
> (kinetic-energy [speed 1] [mass 2])
1
> (kinetic-energy [speed 2] [mass 2])
4
```

```racket
> (require named-arguments/curly-braces)
> (define (kinetic-energy {mass 0} {speed 0})
    (* 1/2 mass (* speed speed)))
> (kinetic-energy {mass 1} {speed 1})
1/2
> (kinetic-energy {speed 1} {mass 2})
1
> (kinetic-energy {speed 2} {mass 2})
4
```

