---
permalink: "/en/workflow/"
title: "A Scalable Workflow"
undone: true
questions:
-   "How can a growing number of people coordinate work on a single project?"
objectives:
-   "Explain what rebasing is and use it interactively to collapse a sequence of commits into a single commit."
-   "Describe a branch-per-feature workflow and explain why to use it."
-   "Describe what a repository tag is and create an annotated tag in a Git repository."
keypoints:
-   "Create a new branch for every feature, and only work on that feature in that branch."
-   "Always create branches from `master`, and always merge to `master`."
-   "Use rebasing to combine several related commits into a single commit before merging."
---

A common Git workflow for single-author/single-user projects is:

1.  Make some changes, running `git add` and `git commit` as you go along.
2.  `git push` to send those changes to a remote repository for backup and sharing.
3.  Switch computers (e.g., go from your laptop to the cluster where you're going to process full-sized data sets).
4.  `git pull` to get your changes from the remote repository,
    and possibly resolve merge conflicts if you made some changes on the cluster the last time you were there
    but forgot to push them to the remote repo.

Occasionally,
you'll run `git checkout -- .` or `git reset --hard VERSION` to discard changes.
Less frequently,
you'll use `git diff -r abcd1234 path/to/file` or `git show abcd1234:path/to/file`
to look at what's changed in files,
or `git checkout abcd1234 path/to/file` followed by `git add` and `git commit`
to restore an old version of a file.
And every once in a while,
you'll [jenny](#g:jenny) the repository and clone a new copy because everything is messed up.

This workflow essentially uses Git to do backups and as a replacement for `scp`
(or `ftp`, if you're of an older generation).
But sometimes you have to work on several things at once in a single project,
or need to set aside current work for a high-priority interrupt.
And even if those situations don't arise,
this workflow doesn't provide guidance for collaborating with others.

This lesson introduces a few working practices that will help you do these things.
Along the way, it shows you how to use some of Git's more advanced capabilities.
As with everything involving Git,
the syntax for commands is more complicated than it needs to be [Pere2013,Pere2016](#BIB),
but if used carefully,
they can make you much more productive.

## How can I use branches to manage development of new features? {#s:workflow-branch}

Experienced developers tend to use a [branch-per-feature workflow](#g:branch-per-feature-workflow),
even when they are working on their own.
Whenever they want to create a new feature, fix a bug, run a new analysis,
or do anything else that might eventually wind up being committed to the repository,
they create a new branch from `master` and do the work there.
When it's done,
they merge that branch back into `master.

More specifically,
a branch-per-feature workflow looks like this:

1.  `git checkout master` to make sure you're working in the `master` branch.

2.  `git pull origin master` (or `git pull upstream master`) to make sure that
    your starting point is up to date
    (i.e., that the changes you committed while working on the cluster yesterday are now in your local copy,
    or that the fix your colleague did last week has been incorporated).

3.  <code>git checkout -b <em>name-of-feature</em></code> to create a new branch.
    The branch's name should be as descriptive as the name of a function
    or of a file containing source code:
    `"stuff"` or `"fixes"` saves you a couple of seconds of typing when you create the branch,
    and will cost you much more time than that later on
    when you're juggling half a dozen branches
    and trying to figure out what's in each.

4.  Do the work you want to do.
    If some other task occurs to you while you're doing it---for example,
    if you're writing a new function and realize that the documentation for some other function should be updated---*don't*
    do that work in this branch just because you happen to be there.
    Instead,
    commit your changes,
    switch back to `master`,
    create a new branch for the other work,
    and carry on.

5.  Periodically,
    you may <code>git push origin <em>name-of-feature</em></code> to save your work to GitHub.

6.  When the work is done,
    you `git pull origin master` to get any changes that anyone else has put in the master copy
    into your branch
    and merge any conflicts.
    This is an important step:
    you want to do the merge *and test that everything still works* in *your* branch,
    not in `master`.

7.  Finally,
    use `git checkout master` to switch back to the `master` branch on your machine
    and <code>git merge <em>name-of-feature</em> master</code> to merge your changes into `master`.
    Test it one more time,
    and then `git push origin master` to send your changes to the remote repository
    for everyone else to admire and use.

It takes longer to describe this workflow than to use it.
Right now,
for example,
I have six active branches in the repository for this material:
`master` (which is the published version),
`explain-branch-per-feature` (which is where I'm writing this),
and four others that I've created from `master` to remind myself to fix a glossary entry,
to rewrite the description in `README.md` of how to generate a PDF of these notes,
and so on.
I am essentially using branches as a to-do list,
which is no more expensive than typing a brief note about the feature into a text file
or writing it in a lab notebook,
and much easier to share.

## How should I think about branches and features? {#s:workflow-thinking}

-   What's hard about branch-per-feature?
    -   Doing work in one branch while large refactoring is going on in another
    -   So don't do this
-   But what's a "feature"?
    -   A pure addition that doesn't change anything else (e.g., a new analysis run)
    -   A change that you might want to undo as a unit
    -   E.g., a new parameter with configuration, option parsing, help, and effect on execution
    -   If you then re-run analyses, do those as separate features (because you might want to undo them separately)

## How can I make it easy for people to review my work before I merge it? {#s:workflow-pull-request}

-   Create a [pull request](#g:pull-request) on GitHub
-   Within one repository (which may be shared with other people) or between repositories (from your fork to the upstream repository)
-   Get someone to look over the changes and leave comments
-   Make fixes: the pull request is updated in place
-   Merge when done

## How can I switch between branches when work is only partly done? {#s:workflow-switching}

-   Don't do several things in one branch
-   Commit work (don't use `git stash`)
-   Do the other thing
-   Squash the history (described below)
-   Merge to `master`
-   Merge from master to the original branch

## How Can I Keep My Project's History Clean When Working on Many Branches? {#s:workflow-rebase}

-   [Rebasing](#g:rebase) means moving or combining some commits from one branch to another
    -   Replay changes on one branch on top of changes made to another
    -   And/or collapse several consecutive commits into a single commit
    -   We will just use the latter ability
-   `git rebase -i BASE`
    -   `BASE` is the most recent commit *before* the sequence to be compressed
    -   Which is always confusing
-   Brings up a display of recent commits
    -   `pick` the first and `squash` the rest
    -   Then see the combination of recent changes and messages
    -   Edit to combine into one
-   Why go to this trouble?
    -   Because you may have done a commit, switched branches to work on something else, and then come back
    -   (You could use `git stash`, but that just makes life even more confusing)
    -   Or it may have taken you several tries to get something right
    -   Either way, only want one change in the final log in order to make undo and comprehension easier
-   What if you have pushed a branch to GitHub (or elsewhere) and then combine the commits to change its history?
    -   Use `git push --force` to overwrite the remote history
    -   This is a sign that you should have done something differently a while back
    -   "It's tough to make predictions, especially about the future" - Yogi Berra
-   Don't rebase branches that are shared with other people
    -   Creating a pull request from a branch effectively makes that branch shared

## How Can I Label Specific Versions of My Work? {#s:workflow-tag}

-   A [tag](#g:git-tag) is a permanent label on a particular state of the repository
    -   Theoretically redundant, since the [commit hash](#g:commit-hash) identifies that state as well
    -   But commit hashes are (deliberately) random and therefore hard to remember or find
-   Use [annotated tags](#g:annotated-tag) to mark every major event in the project's history
    -   Annotated because they allow a message, just like a commit
-   Software projects use [semantic versioning](#g:semantic-versioning) for software releases
    -   `major.minor.patch`
    -   Increment `major` every time there's an incompatible externally-visible change
    -   Increment `minor` when adding functionality without breaking any existing code
    -   Increment `patch` for bug fixes that don't add any new features ("now works as previously documented")
-   Research projects often use `report-date-event` instead of semantic versioning
    -   E.g., `jse-2018-06-23-response` or `pediatrics-2018-08-15-summary`
    -   Do not tempt fate by calling something `-final`
-   For simple projects, only tag the master branch
    -   Because everything that is finished is merged to master
-   Larger software projects may create a branch for each released version and do minor or patch updates on that branch
    -   Outside the scope of this lesson

## Summary {#s:workflow-summary}

FIXME: create concept map for workflow

{% include links.md %}
