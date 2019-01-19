---
root: true
redirect_from: "/"
permalink: "/en/"
---

> It's still magic even if you know how it's done.
>
> -- Terry Pratchett

As research becomes more computing intensive,
researchers need more computing skills.
Being able to use version control and to write small programs and shell scripts is a start;
these lessons will help you take your next steps so that:

-   other people (including your future self) can re-do your analyses;
-   you and the people using your results can be confident that they're correct; and
-   re-using your software is easier than rewriting it.

This guide is the second part of [Merely Useful][config-organization],
and all material is [available online][config-website].
The [first part][one-extra-fact]
covers what every researcher and data analyst ought to know
in order to get results on their own.
This part covers what is needed to get results in production,
when other people depend on the results.
The two guides cannot teach you everything you need to know,
but we hope they will turn some unknown unknowns into known unknowns
and help you figure out what you ought to learn about next.

## Who Are These Lessons For? {#s:index-personas}

Amira
:   completed a Master's in library science five years ago,
    and has worked since then for a small NGO.
    She did some statistics during her degree,
    and has learned some R and Python by doing data science courses online,
    but has no formal training in programming.
    Amira would like to tidy up the scripts, data sets, and reports she has created
    in order to share them with her colleagues.
    These lessons will show her how to do this and what "done" looks like.

Jun
:   completed an [Insight Data Science][insight] fellowship last year after doing a PhD in Geology,
    and now works for a company that does forensic audits.
    He has used a variety of machine learning and visualization software,
    and has made a few small contributions to a couple of open source R packages.
    He would now like to make his own code available to others;
    this guide will show him how such projects should be organized.

Sami
:   learned a fair bit of numerical programming while doing a BSc in applied math,
    then started working for the university's supercomputing center.
    Over the past few years,
    the kinds of applications they are being asked to support
    have shifted from fluid dynamics to data analysis.
    This guide will teach them how to build and run data pipelines
    so that they can teach those skills to their users.

## Summary {#s:index-summary}

For researchers and data scientists who can build and run programs that are three or four pages long,
and who want to be more productive and have more confidence in their results,
this guide
provides a pragmatic, tools-based introduction to program design and maintenance.
Unlike books and courses aimed at computer scientists and professional software developers,
this guide uses data analysis as a motivating example
and assumes that the learner's ultimate goal is to answer questions rather than ship products.

Learners must be comfortable with the basics of
the [Unix shell][swc-shell], [Python][swc-python] or [R][swc-r], and [Git][swc-git].
They will need a personal computer with Internet access,
the Bash shell,
Python 3,
and a GitHub account.

## Contributing {#s:index-contributing}

{% include contributing.md %}

{% include links.md %}
