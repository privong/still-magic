---
title: "Managing Backlog"
questions:
-   "How can I tell what needs to be done and who is doing it?"
objectives:
-   "Explain what an issue tracking tool does and what it should be used for."
-   "Explain how to use labels on issues to manage work."
-   "Describe the information a well-written issue should contain."
keypoints:
-   "Create issues for bugs, enhancement requests, and discussions."
-   "Add people to issues to show who is responsible for working on what."
-   "Add labels to issues to identify their purpose."
-   "Use rules for issue state transitions to define a workflow for a project."
---

Version control tells us where we've been;
[issues](#g:issue) tells us where we're going.
Issue tracking tools are often called ticketing systems or bug trackers
because they were created to keep track of work that needs to be done and bugs that needed fixing.
However,
they can be used to manage any kind of work
and are often a convenient way to manage discussions as well.

## How can I manage the work I still have to do? {#s:backlog-issues}

Like other [forges](#g:forge),
GitHub records a set of issues for each project,
and allows members of that project to create new ones,
modify existing ones,
and search both.
Every issue has:

-   A unique ID, such as `#123`, which is also part of its link.
    This makes issues easy to find and refer to:
    in particular, GitHub automatically translates the expression `#123` in a [commit message](#g:commit-message)
    into a link to that issue.

-   A one-line title to aid browsing and search.

-   The issue's current status.
    In simple systems (like GitHub's),
    each issue is either open or closed,
    and by default,
    only open issues are displayed.

-   The ID of the issue's creator.
    The IDs of people who have commented on it or modified it are also embedded in the issue's history,
    which helps when using issues to manage discussions.

-   A full description that may include screenshots, error messages, and just about anything else.

-   Replies, counter-replies, and so on from people with an interest in the issue.

Broadly speaking,
people create three kinds of issues:

1.  *Bug reports* to describe problems they have encountered.
    A good bug report is a work of art,
    so we discuss them in detail [below](#s:backlog-bugs).

2.  *Feature requests* (for software packages)
    or *tasks* (for projects).
    These issues are the other kind of [work backlog](#g:backlog) in a project:
    not "what needs to be fixed" but "what do we want to do next".

3.  *Questions*.
    Many projects encourage people to ask questions on a mailing list or in a chat channel,
    but answers given there can be hard to find later,
    which leads to the same questions coming up over and over again.
    If people can be persuaded to ask questions by filing issues,
    and to respond to issues of this kind,
    then the project's old issues become a customized [Stack Overflow][stack-overflow] for the project.
    (In practice,
    most projects find that it's easier to create a page of links to old questions and answers,
    or to rely on search to find things,
    since using issues this way requires someone to put in curation time.)

## How can I write a good bug report? {#s:backlog-bugs}

The better the bug report,
the faster the response,
and the more likely the response will actually address the issue [Bett2008](#BIB).

1.  Make sure the problem actually *is* a bug.
    It's always possible that you have called a function the wrong way
    or done an analysis using the wrong configuration file;
    if you take a minute to double-check,
    you could well fix the problem yourself.
2.  Try to come up with a [reproducible example](#g:reprex), or reprex.
    A reprex includes only the steps or lines of code needed to make the problem happen;
    again, you'll be surprised how often you can solve the problem yourself
    as you trim down your steps to create one.
3.  Write a one-line title for the issue
    and a longer (but still brief) description that includes relevant details).
4.  Attach any screenshots that show the problem or (slimmed-down) input files needed to re-create it.
5.  Describe the version of the software you were using,
    the operating system you were running on,
    and anything else that might affect behavior.
6.  Describe each problem separately so that each one can be tackled on its own.
    (This parallels the rule about creating a branch in version control for each bug fix or feature
    discussed in [s:branches](#REF).)

Here's an example of a well-written bug report with all of the fields mentioned above:

```text
ID: 1278
Creator: standage
Owner: malvika
Labels: Bug, Assigned
Summary: wordbase.py fails on accented characters
Description:

1.  Create a text file called 'accent.txt' containing the word "Pumpernickel"
    with an umlaut over the 'u'.

2.  Run 'python wordbase.py --all --message accent.txt'

Program should print "Pumpernickel" on a line by itself with the umlaut, but
instead it fails with the message:

    No encoding for [] on line 1 of 'accent.txt'.

([] shows where a solid black box appears in the output instead of a
printable character.)

Versions:
-   `python wordbase.py --version` reports 0.13.1
-   Using on Windows 10.
```
{: title="backlog/bug_report.txt"}

## How can I use labels to organize work? {#s:backlog-label}

There is always more work to do than there is time to do it.
Issue trackers let project members add [labels](#g:issue-label) to issues to manage this.
A label is just a word or two;
GitHub allows project owners to create any labels they want
that users can then add to their issues.
A small project should always use these four labels:

-   *Bug*: something should work but doesn't.
-   *Enhancement*: something that someone wants added.
-   *Task*: something needs to be done, but won't show up in code
    (e.g., organizing the next team meeting).
-   *Discussion*: something the team needs to make a decision about.
    (All issues can have discussion---this category is for issues that start that way.)

<!-- == noindent -->
It might also use:

-   *Question*: how is something supposed to work (discussed [earlier](#s:backlog-issues)).
-   *Suitable for Newcomer* or *Beginner-Friendly*:
    to identify an easy starting point for someone who has just joined the project.
    If you help potential new contributors find places to start,
    they're more likely to do so [Stei2014](#BIB).

## How can I use labels to prioritize work? {#s:backlog-triage}

The labels listed above described what kind of work an issue describes;
a separate set of labels can be used to indicate how important that work is.
These labels typically have names like "High Priority" or "Low Priority";
their purpose is to help [triage](#g:triage),
which is the process of deciding what is going to be worked on in what order.

In a large project,
this is the responsibility of the product manager ([s:process](#REF));
in a small one,
it's common for the project's lead to decide this,
or for project members to use up-votes and down-votes on an issue
to indicate how important they think it is.

However the decision is made,
it's helpful to use six more labels to record the outcomes:

-   *Urgent*: this needs to be done *now*
    (typically reserved for security fixes).
-   *Current*: this issue is included in the current round of work.
-   *Next*: this issue is (probably) going to be included in the next round.
-   *Eventually*: someone has looked at the issue and believes it needs to be tackled,
    but there's no immediate plan to do it.
-   *Won't Fix*: someone has decided that the issue isn't going to be addressed,
    either because it's out of scope or because it's not actually a bug.
    Once an issue is marked this way,
    it is usually then closed.
-   *Duplicate*: this issue is a duplicate of one that's already in the system.
    Again,
    issues marked this way are usually then closed.

Larger projects will replaced "Current", "Next", and "Eventually"
with labels corresponding to upcoming software releases, journal issues, or conferences.
Unfortunately,
this doesn't work well on GitHub's issue tracking system,
since there's no way to "retire" a label without deleting it.
After a while,
a project that uses labels for specific events can have a *lot* of old labels...

## How can I use issues to enforce a workflow for a project? {#s:backlog-workflow}

If you're using GitHub,
the short answer to this section's title question is,
"You can't,"
but you can create conventions,
and more sophisticated issue tracking systems will let you enforce those conventions.
The basic idea is to only allow issues to move from some states to others,
and to only allow some people to move them.
For example,
[f:backlog-lifecycle](#FIG) shows a workflow for handling bugs in a medium-sized project:

{% include figure.html id="f:backlog-lifecycle" src="lifecycle.svg" caption="Issue State Transitions" %}

-   An "Open" issue becomes "Assigned" when someone is made responsible for it.
-   An "Assigned" issue becomes "Active" when that person starts to work on it.
-   If they stop work for any length of time, it becomes "Suspended".
    (That way, people who are waiting for it know not to hold their breath.)
-   An "Active" bug can either be "Fixed" or "Cancelled",
    where the latter state means that the person working on it has decided it's not really a bug.
-   Once a bug is "Fixed",
    it can either be "Closed" or, if the fix doesn't work properly,
    moved back into the "Open" state and go around again.

Workflows like this are more complex than small projects need,
but as soon as the team is distributed---particularly distributed across timezones---it's
very helpful to be able to find out what's going on
without having to wait for someone to be awake.

## Summary {#s:backlog-summary}

FIXME: create concept map for workflow

## Exercises {#s:backlog-exercises}

FIXME: exercises for backlog chapter.

{% include links.md %}
