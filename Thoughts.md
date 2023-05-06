# Thoughts

Here we collect some random thoughts.

## dynamics & time derivatives

- Usually, dynamical EoMs are >= 2nd order in time. The initial data is given by the position $x$ and the momentum $p\sim\dot{x}$, upon which one can construct a phase space endowed with a symplectic structure.
- Schrodinger & Dirac equation are 1st order in time. However, a phase space is still present because the initial data $\psi$ is complex. In these cases we actually have a coupled system of 1st order equations, which can be re-written into 2nd order ones.

## class inheritance is bad

The first full fledged programming languages that I studied in school are python (which I enjoy a lot) and C++ (which I never actually learned), both of them follows traditional class inheritance OOP paradigm. Naturally I assume that this is the way to write a modern program. I was deceived and I suffered from it.

Once upon a time I was curious why the linux kernel thrives with plain C without classes. Had I looked closer, I would have found out the secret a couple years earlier, but I did not. Hence much of my youth was wasted juggling class inheritance. The recent revelation came when I discover that the milestone for modern language, rust, does not have traditional classes. It turns out that other ways to do OOP, that make use of the type system. See https://rosettacode.org/wiki/Abstract_type.
