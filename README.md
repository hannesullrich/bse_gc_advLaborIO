# Advanced Econometrics in Labor and IO
## Berlin School of Economics and DIW Graduate Center, Spring 2022


---

## Course organization

- **This repository will provide all material to *prepare for sessions*. All posted papers must be *thoroughly read* in advance. The class will be interactive.**

- The class uses Matlab. If you have issues obtaining a Matlab license, Julia is a free and very powerful alternative with similar basic syntax. Feel free to use [Julia](https://julialang.org) though feedback on code may be more limited if you do. A good way to use Julia is in an IDE such as [Julia for VS Code](https://www.julia-vscode.org/docs/stable/), based on the [VS code](https://code.visualstudio.com) editor.

- 	Instructors: [Peter Haan](https://www.diw.de/cv/en/phaan), [Luke Haywood](http://www.lukehaywood.eu/), [Boryana Ilieva](https://www.diw.de/cv/en/bilieva), and [Hannes Ullrich](https://www.hannesullrich.com)

-   The course takes place on Thursdays, 14:00 - 17:00 (see some session-specific changes)

-   This is an in-person class at DIW Berlin, room Karl Popper (2.3.020)

-   Credit points: 9 ECTS. 9 three hour sessions + final exam session

-   First session: April 28th, 2022

-   Final session: July 14th (Exam), 2022

-   Compulsory reading in bold

-   Evaluation: if this course is taken for credits, the final grade
    will be determined by

    -   2 problem sets (to be completed in groups of max. 2
        participants), weighted 1/3 each, and

    -   a final exam, weighted 1/3.

---

## Course objectives

-   Discuss advantages and limitations of structural econometric models.
    Give students an understanding of why and when adding structure is
    important.

-   Provide insights into strategy (especially, identification) in
    important papers in structural Labour, Public & IO literature. Give
    a feel of how one may go about establishing a structural model.

-   Establish basic estimation techniques & numerical methods such as
    Simulation, Numerical integration and Discretisation.

-   Develop matrix programming skills using Matlab. Loops vs.
    vectorisation; readability vs. speed; sustainable coding for several
    projects.


---

## Session 1: Introduction to Structural Discrete Choice Modeling

-   April 28, 14:00 - 17:00

-   Instructor: Peter Haan

-   **Numerical methods**: Judd (1998), Train (2009)

-   **Methodology fights**: Angrist and Pischke (2010), Frijters (2013),
    Heckman (2010), Keane (2010), Rust (2010), Rust (2014),
    Wolpin (2013)

### References

-   Angrist, Joshua and Jörn Pischke (2010), "The Credibility Revolution
    in Empirical Economics: How Better Research Design is Taking the Con
    out of Econometrics,\" *Journal of Economic Perspectives* 24 (2),
    3-30.

-   Frijters, Paul (2013) "The Limits of Inference Without Theory",
    *Economic Record* 89, 429-432.

-   Heckman, Jim J. (2010), "Building Bridges Between Structural and
    Program Evaluation Approaches to Evaluating Policy,\" *Journal of
    Economic Literature* 48(2), 356-398.

-   Judd, Kenneth L. (1998), *Numerical Methods in Economics*, MIT
    Press, Cambridge, MA.

-   Keane, Michael P. (2010), "Structural vs. Atheoretic Approaches to
    Econometrics,\" *Journal of Econometrics* 156, 3-20.

-   Rust, John (2010), "Comments on: 'Structural vs. atheoretic
    approaches to econometrics' by Michael Keane,\" *Journal of
    Econometrics* 156 (1), 21-24.

-   Rust, John (2014), "The Limits of Inference with Theory: A Review of
    Wolpin,\" *Journal of Economic Literature* 52 (3), 820-850.

-   Train, Kenneth E. (2009), Discrete Choice Methods with Simulation,
    Cambridge University Press.

-   Wolpin, Kenneth I. (2013), The limits of inference without theory,
    MIT Press.


---
## Session 2: Static discrete choice in IO

-   May 5, 14:15 - 17:15

-   Instructor: Hannes Ullrich

-   Estimating demand and supply parameters in markets with
    differentiated products using aggregate (product-level) data

-   Coding exercise: preliminaries

### References

-   Ackerberg, D., L. Benkard, S. Berry, and A. Pakes (2007),
    "Econometric Tools for Analyzing Market Outcomes,\" in J. J. Heckman
    and E. Leamer, eds., *Handbook of Econometrics*, North-Holland,
    Chapter 63, 4171-4276, Section 1.

-   **Berry, Steven T. (1994), "[Estimating Discrete Choice Models of
    Product Differentiation](pre-class-readings/week2/Berry1994.pdf),\" *Rand Journal of Economics* 25 (2),
    242-262.**

-   **Berry, Steven T., Jim Levinsohn, and Ariel Pakes (1995),
    "[Automobile Prices in Market Equilibrium](pre-class-readings/week2/BerryEtAl1995.pdf),\" *Econometrica* 63 (4),
    841-890.**

-   Berry, Steven T. and Philip A. Haile (2021), “Foundations of Demand Estimation,” In *Handbook of Industrial Organization* 4(1), 1-62.

-   Haile, Phil (2021), “Structural vs. Reduced Form:” Language, Confusion, and Models in Empirical Economics, slides at http://www.econ.yale.edu/~pah29/intro.pdf

-   Reiss, P. and F. Wolak (2007), "Structural econometric modeling:
    Rationales and examples from industrial organization,\" in J. J.
    Heckman and E. Leamer, eds., *Handbook of Econometrics*,
    North-Holland, Chapter 64, 4277-4415.


---
## Session 3: Static discrete choice in IO

-   May 12, 14:15 - 17:15

-   Instructor: Hannes Ullrich

-   Recap Berry et al. (1995)

-   Coding exercise: Berry et al. (1995) nested fixed-point (NFP)
    algorithm

-   Discuss extensions and alternative estimation methods

### References

-   **Berry, Steven T., Jim Levinsohn, and Ariel Pakes (1995),
    "[Automobile Prices in Market Equilibrium](pre-class-readings/week2/BerryEtAl1995.pdf),\" *Econometrica* 63 (4),
    841-890.**

-   **Conlon, Christopher and Jeff Gortmaker (2020), “[Best Practices for Differentiated Products Demand Estimation with pyblp](pre-class-readings/week2/ConlonGortmaker2020_BestPracticesBLP.pdf),” *Rand Journal of Economics* 51(4), 1108-1161.**

-   Nevo, Aviv (2000), "[A Practitioner's Guide to Estimation of
    Random-coefficients Logit Models of Demand](pre-class-readings/week3/Nevo2000.pdf),\" *Journal of Economics
    and Management Strategy* 9 (4), 513-548.


---
## Session 4: Dynamic discrete choice in IO

-   May 19, 14:15 - 17:00

-   Instructor: Hannes Ullrich

-   Introduction to dynamics

-   Estimating single-agent discrete choice models: Rust (1987) engine
    replacement problem

### References

-   Magnac, Thierry and David Thesmar (2002), "Identifying dynamic
    discrete decision processes,\" *Econometrica* 70 (2), 801-816.

-   **Rust, John (1987), "[Optimal replacement of GMC bus engines: An
    empirical model of Harold Zurcher](pre-class-readings/week4/Rust1987.pdf),\" *Econometrica* 55, 999-1033.**

-   **Rust, John (1994), [Structural estimation of Markov decision
    processes](pre-class-readings/week4/Rust1994.pdf), In R. Engle and D. McFadden (Eds.), *Handbook of
    Econometrics* 4, 3081-3143, North-Holland. Amsterdam.**


---
## Session 5: Dynamic discrete choice in IO

-   June 2, 14:15 - 16:45

-   Instructor: Hannes Ullrich

-   Coding exercise: Rust (1987)

-   Conditional choice probability (CCP) estimation

### References

-   Arcidiacono, Peter and Paul B. Ellickson (2011), "Practical methods
    for estimation of dynamic discrete choice models,\" *Annual Review
    of Economics*, 3, 363-394.

-   Gowrisankaran, Gautam and Marc Rysman (2012), "Dynamics of consumer
    demand for new durable goods,\" *Journal of Political Economy*
    120(6), 1173-1219.

-   Hotz, Joseph V. and David A. Miller (1993), "Conditional choice
    probabilities and the estimation of dynamic models,\" *Review of
    Economic Studies* 60, 497-529.

-   Hotz, Joseph V., David A. Miller, S. Sanders, and J. Smith (1994),
    "A simulation estimator for dynamic models of discrete choice,\"
    *Review of Economic Studies* 61(2), 265-289.


---
## Session 6: Dynamic discrete choice in Labour I

-   June 9, 14:15 - 17:15

-   Instructors: Peter Haan, Boryana Ilieva

-   Dynamic incentives to labour supply: investing in human capital

-   More on Discretisation

-   Interpolation

### Reference

-   Keane, M., P. Todd, and K. Wolpin (2011), "The Structural Estimation
    of Behavioral Models: Discrete Choice Dynamic Programming Methods
    and Applications,\" in *Handbook of Labor Economics*, ed. by O.
    Ashenfelter and D. Card, Elsevier, vol. 4, 1 ed.

-   **Keane, Michael and Kenneth Wolpin (1997), "[The Career Decisions of Young Men](pre-class-readings/week6/KeaneWolpin1997.pdf)", *Journal of Political Economy* 105 (3), 473-522.**


---
## Session 7: Dynamic discrete choice in Labour II

-   June 16, 14:15 - 17:15

-   Instructors: Peter Haan, Boryana Ilieva

-   Dynamic incentives to labour supply: the role of education, full
    time and part time experience

-   Identification and validation of structural parameters

-   Policy Simulation

### Reference

-   **Blundell, Richard, Monica Costa-Dias, Costas Meghir, and Jonathan
    Shaw (2016), "[Female Labour Supply, Human Capital and Welfare
    Reform](pre-class-readings/week7/Blundelletal2016.pdf)", *Econometrica* 84(5), 1705-1753.**


---
## Session 8: Dynamic discrete choice in Labour III

-   June 23, 14:15 - 17:15

-   Instructors: Peter Haan, Boryana Ilieva

-   Dynamic incentives to labour supply: the role of education, full
    time and part time experience

-   Identification and validation of structural parameters

-   Policy Simulation

### Reference

-   **Blundell, Richard, Monica Costa-Dias, Costas Meghir, and Jonathan
    Shaw (2016), "[Female Labour Supply, Human Capital and Welfare
    Reform](pre-class-readings/week7/Blundelletal2016.pdf)", *Econometrica* 84(5), 1705-1753.**


---
## Session 9: Partial job search

-   June 30, 14:15 - 17:15

-   !Change in location: DIW Berlin, room Anna J. Schwarz (5.2.010)

-   Instructor: Luke Haywood

-   Discuss motivation and rationale of job search models

-   Understand optimal job search decisions

-   Non-parametric identification & estimation using duration data

-   Simulation using inverse probability sampling

### References

-   **John McCall (1970) "[The Economics of Information and Job Search](pre-class-readings/week9/McCall_1970.pdf),
    *Quarterly Journal of Economics*, 84, p.113-126**

-   **Christopher Flinn & James Heckmann (1982)"[New Methods for
    Analyzing Structural Models of Labor Force Dynamics](pre-class-readings/week9/flinn-heckman-1982.pdf)", *Journal of
    Econometrics* 18, 115-168.**

-   Richard Rogerson, Robert Shimer & Randall Wright (2005),
    "Search-Theoretic Models of the Labor Market: A Survey", *Journal of
    Economic Literature* 43, 115-168.

-   **Kenneth Train (2009), "[Chapter 9 - Drawing from Densities](pre-class-readings/week9/Train-Ch09_p205-236.pdf)" *in*
    "Discrete Choice Methods with Simulation", Cambridge University
    Press & https://eml.berkeley.edu/books/choice2.html**


---
## Session 10: Equilibrium job search

-   July 7, 14:15 - 17:15

-   Instructor: Luke Haywood

-   Contrast optimal stopping to equilibrium job search models

-   Discuss how on-the-job search generates wage dispersion of
    observationally equivalent workers

-   Simulation & estimation of the model

### References

-   Peter Diamond (1971) "A model of Price Adjustment", *Journal of
    Economic Theory* 3, 156-168.

-   James Albrecht & Bo Axell (1984) " An Equilibrium Model of Search
    Unemployment" (1998), *Journal of Political Economy* 92, 824-840.

-   **Burdett, Kenneth and Dale Mortensen "[Wage Differentials Employer
    Size and Unemployment](pre-class-readings/week10/Burdett_Mortensen_1998.pdf)" (1998), *International Economic Review* 39
    (2), 257-273.**

-   Gerard Van Den Berg (1999) "Empirical inference with equilibrium
    search models of the labour market." *The Economic Journal* 109,
    p.283-306.


---
## Session 11: Final Exam

-   July 14, 14:15 - 17:15

