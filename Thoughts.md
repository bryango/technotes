# Thoughts

Here we collect some random thoughts.

## class inheritance is bad

The first full fledged programming languages that I studied in school are python (which I enjoy a lot) and C++ (which I never actually learned), both of which follow traditional class inheritance OOP paradigm. Naturally I assume that this is the way to write a modern program. I was deceived and I suffered from it.

Once upon a time I was curious why the linux kernel thrives with plain C without classes. Had I looked closer, I would have found out the secret a couple years earlier, but I did not. Hence much of my youth was wasted juggling class inheritance. The recent revelation came when I discover that the milestone for modern language, rust, does not have traditional classes. I find out that:

- often we do not need classes at all, and we should follow the more naive paradigm of functional programming
- or we should use a better way to do OOP.

It turns out that other ways to do OOP, that make use of the type system. See https://rosettacode.org/wiki/Abstract_type. The following concepts are roughly the same:

- Traits in rust: https://doc.rust-lang.org/book/ch10-02-traits.html
- Protocols in python: https://peps.python.org/pep-0544/
- Interfaces in many languages: https://en.wikipedia.org/wiki/Interface_(object-oriented_programming)

This forces the design of [_composition over inheritance_](https://en.wikipedia.org/wiki/Composition_over_inheritance), which is much more versatile. Only use traditional classes if:

- class methods are tightly coupled
- only simple inheritances are required

# previous thoughts

## dynamics & time derivatives

- Usually, dynamical EoMs are >= 2nd order in time. The initial data is given by the position $x$ and the momentum $p\sim\dot{x}$, upon which one can construct a phase space endowed with a symplectic structure.
- Schrodinger & Dirac equation are 1st order in time. However, a phase space is still present because the initial data $\psi$ is complex. In these cases we actually have a coupled system of 1st order equations, which can be re-written into 2nd order ones.

