---
title: "Refactoring"
questions:
-   "How can I improve code that already works?"
objectives:
-   "Describe at least four common refactorings and correctly apply each."
keypoints:
-   "Reorganizing code in consistent ways makes errors less likely."
-   "Replace a value with a name to make code more readable and to forestall typing errors."
-   "Replace a repeated test with a flag to ensure consistency."
-   "Turn small pieces of large functions into functions in their own right, even if they are only used once."
-   "Combine functions if they are always used together on the same inputs."
-   "Use lookup tables to make decision rules easier to follow."
-   "Use comprehensions instead of loops."
---

[Refactoring](#g:refactor) means changing the structure of code without changing what it does,
like refactoring an equation to simplify it.
It is just as much a part of programming as writing code in the first place:
nobody gets things right the first time [Bran1995](#BIB),
and needs or insights can change over time.

Most discussions of refactoring focus on [object-oriented programming](#g:oop),
but many patterns can and should be used to clean up [procedural](#g:procedural-programming) code.
This lesson describes and motivates some of the most useful patterns;
These rules are examples of [design patterns](#g:design-patterns):
general solutions to commonly occurring problems in software design.
Knowing them and their names will help you create better software,
and also make it easier for you to communicate with your peers.

## How can I avoid repeating values in code? {#s:refactor-replace-value-with-name}

Our first and simplest refactoring is called "replace value with name".
It tells us to replace magic numbers with names,
i.e., to define constants.
This can seem ridiculous in simple cases
(why define and use `inches_per_foot` instead of just writing 12?).
However,
what may be obvious to you when you're writing code won't be obvious to the next person,
particularly if they're working in a different context
(most of the world uses the metric system and doesn't know how many inches are in a foot).
It's also a matter of habit:
if you write numbers without explanation in your code for simple cases,
you're more likely to do so for complex cases,
and more likely to regret it afterward.

Using names instead of raw values also makes it easier to understand code when you read it aloud,
which is always a good test of its style.
Finally,
a single value defined in one place is much easier to change
than a bunch of numbers scattered throughout your program.
You may not think you will have to change it,
but then people want to use your software on Mars and you discover that constants aren't [Mak2006](#BIB).

{% include refactor/replace_value_with_name.html %}

## How can I avoid repeating calculations in code? {#s:refactor-hoist-repeated}

It's inefficient to calculate the same value over and over again.
It also makes code less readable:
if a calculation is inside a loop or a function,
readers will assume that it might change each time the code is executed.

Our second refactoring,
"hoist repeated calculation out of loop",
tells us to move the repeated calculation out of the loop or function.
Doing this signals that its value is always the same.
And by naming that common value,
you help readers understand what its purpose is.

{% include refactor/hoist_repeated_calculation.html %}

## How can I make repeated conditional tests clearer? {#s:refactor-repeated-test}

Novice programmers frequently write conditional tests like this:

```python
if (a > b) == True:
    # ...do something...
```

<!-- == noindent -->
The comparison to `True` is unnecessary because `a > b` is a Boolean value
that is itself either `True` or `False`.
Like any other value,
Booleans can be assigned to variables,
and those variables can then be used directly in tests:

```python
was_greater = estimate > 0.0
# ...other code that might change estimate...
if was_greater:
    # ...do something...
```

<!-- == noindent -->
This refactoring is called "replace repeated test with flag".
When it is used,
there is no need to write `if was_greater == True`:
that always produces the same result as `if was_greater`.
Similarly, the equality tests in `if was_greater == False` is redundant:
the expression can simply be written `if not was_greater`.
Creating and using a [flag](#g:flag) instead of repeating the test
is therefore like moving a calculation out of a loop:
even if that value is only used once,
it makes our intention clearer---these really are the same test.

{% include refactor/replace_repeated_test_with_flag.html %}

<!-- == noindent -->
If it takes many lines of code to process data and create a score,
and the test then needs to change from `>` to `>=`,
we're more likely to get the refactored version right the first time,
since the test only appears in one place and its result is given a name.

## How can I avoid duplicating expressions in assignment statements? {#s:refactor-in-place}

An [in-place operator](#g:in-place-operator),
sometimes called an [update operator](#g:update-operator),
does a calculation with two values
and overwrites one of the values.
For example,
instead of writing:

```python
step = step + 1
```

<!-- == noindent -->
we can write:

```python
step += 1
```

In-place operators save us some typing.
They also make the intention clearer,
and most importantly,
they make it harder to get complex assignments wrong.
For example:

```python
samples[least_factor_index, max(current_offset, offset_limit)] *= scaling_factor
```

<!-- == noindent -->
is much easier to read than the equivalent expression:

```python
samples[least_factor_index, max(current_offset, offset_limit)] = \
    scaling_factor * samples[least_factor_index, max(current_limit, offset_limit)]
```

<!-- == noindent -->
(The proof of this claim is that you probably didn't notice on first reading
that the long form uses different expressions to index `samples`
on the left and right of the assignment.)
The refactoring "use in-place operator" does what its name suggests:
converts normal assignments into their briefer equivalents.

{% include refactor/use-in-place-operator.html %}

## How can I make special cases easier to spot? {#s:refactor-short-circuits}

A [short circuit test](#g:short-circuit-test) is a quick check to handle a special case,
such as checking the length of a list of values
and returning `math.nan` for the average if the list is empty.
"Place short circuits early" tells us to put short-circuit tests near the start of functions
so that readers can mentally remove special cases from their thinking
while reading the code that handles the usual case.

{% include refactor/place-short-circuits-early.html %}

A related refactoring pattern is called "default and override".
To use it,
find cases where a value is set conditionally;
assign the default or most common value unconditionally,
and then override it in a special case.
The result is fewer lines of code and clearer control flow;
however,
it does mean executing two assignments instead of one,
so it shouldn't be used if the common case is expensive
(e.g., involves a database lookup or a web request).

{% include refactor/default-and-override.html %}

In simple cases,
people will sometimes put the test and assignment on a single line:

```python
scale = 1.0
if configuration['threshold'] > UPPER_BOUND: scale = 0.8
```

<!-- == noindent -->
Some programmers take this even further
and use a [conditional expression](#g:conditional-expression):

```python
scale = 0.8 if configuration['threshold'] > UPPER_BOUND else 1.0
```

<!-- == noindent -->
However,
this puts the default last instead of first,
which is less clear.

## How can I divide code into more comprehensible chunks? {#s:refactor-extract-function}

Functions were created so that programmers could write common operations and re-use them
in order to reduce the amount of code that needed to be compiled.
It turns out that moving complex operations into functions also reduces [cognitive load](#g:cognitive-load):
by reducing the number of things that have to be understood simultaneously.

{% include refactor/extract-function.html %}

You should always extract functions when code can be used in other contests.
Even if it can't,
you should extract functions whenever it makes the function clearer
when it is read aloud.
Multi-part conditionals,
parts of long equations,
and the bodies of loops are good candidates for extraction;
if you can't think of a plausible name,
or if a lot of data has to be passed into the function after it's extracted,
the code should probably be left where it is.
Finally,
it's often helpful to keep using the original variable names as parameter names during refactoring
to reduce typing.

## When and how should I combine code into a single function? {#s:refactor-combine-functions}

"Combine functions" is the opposite of "extract function".
If operations are always done together,
it can sometimes be be more efficient to do them together,
and *might* be easier to understand.
However,
combining functions often reduces their reusability and readability;
one sign that functions shouldn't have been combined is
how often people use the combination and throw some results away.

The fragment below shows how two functions can be combined:

{% include refactor/combine-functions.html %}

<!-- == noindent -->
One thing you may not notice about the combination is that
it assumes characters are either vowels or consonants,
which means it might work differently than separate calls to the two original functions.
Issues like this are why experienced developers write unit tests ([s:unit](#REF))
*before* starting to refactor.

## How can I replace code with data? {#s:refactor-lookup}

It is sometimes easier to understand and maintain lookup tables than complicated conditionals,
so the "create lookup table" refactoring tells us to turn the latter into the former:

{% include refactor/create-lookup-table.html %}

The more distinct cases there are,
the greater the advantage lookup tables have over multi-branch conditionals.
Those advantages multiply when items can belong to more than one category,
in which case the table is often best written as a dictionary with items as keys
and sets of categories as values:

```python
LETTERS = {
    'A' : {'vowel', 'upper_case'},
    'B' : {'consonant', 'upper_case'},
    # ...other upper-case letters...
    'a' : {'vowel', 'lower_case'},
    'b' : {'consonant', 'lower_case'},
    # ...other lower-case letters...
    '+' : {'punctuation'},
    '@' : {'punctuation'},
    # ...other punctuation...
}

def count_vowels_and_consonants(text):
    num_vowels = num_consonants = 0
    for char in text:
        num_vowels += int('vowel' in LETTERS[char])
        num_consonants += int('consonant' in LETTERS[char])
    return num_vowels, num_consonants
```
{: title="refactor/set_lookup_table.py"}

<!-- == noindent -->
The expressions used to update `num_vowels` and `num_consonants` make use of the fact that
`in` produces either `True` or `False`,
which the function `int` converts to either 1 or 0.
We will explore ways of making this code more readable in the exercises.

## What can I use instead of explicit loops? {#s:refactor-comprehension}

When programmers see a pattern in many different contexts,
they will often add features to the language to support it.
Many language features therefore exist to give programmers something to refactor *to*.

One such feature is called a [list comprehensions](#g:list-comprehension),
which can be used in place of a loop that processes one list to create another.
The word "comprehension" is used in the sense of "comprehensive":
every element of the original list is processed,
and in simple cases,
produces exactly one element in the result.

{% include refactor/simple-comprehension.html %}

List comprehensions can be easier to read than loops for simple calculations,
but they become more complicated to understand when conditional expressions are included.
The `if` case isn't too base:

{% include refactor/comprehension-if.html %}

<!-- == noindent -->
but `if`-`else` is structured differently in comprehensions than it is in a one-line conditional:

{% include refactor/comprehension-else.html %}

Similarly,
cross-product loops are straightforward
(for some definition of "straightforward"):

{% include refactor/cross-product-comprehension.html %}

<!-- == noindent -->
but the equivalent of nested loops in which the inner loop depends on the value of the outer loop
always feels back-to-front:

{% include refactor/nested-comprehension.html %}

Python comprehensions work for sets, dictionaries, and anything else that can be iterated over.

## Summary {#s:refactor-summary}

-   A good test of code quality: each plausible small change to functionality requires one change in one place

FIXME: create concept map for refactoring

## Exercises {#s:refactor-exercises}

<section markdown="1">
### Make lookup tables easier to read

FIXME: make last example of lookup tables easier to read.
</section>

{% include links.md %}
