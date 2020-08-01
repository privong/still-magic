---
permalink: "/en/style/"
title: "Programming Style"
questions:
-   "How should I name my variables and functions?"
-   "How should I organize my code so that other people can understand it?"
-   "What kinds of variables should I create so that my code is easier to understand?"
-   "How can I go about reorganizing code when I'm making changes?"
objectives:
-   "Explain why consistent formatting of code is important."
-   "Describe standard Python formatting rules and identify cases where code does or doesn't conform to them."
-   "Write functions whose parameters have default values."
-   "Explain which parameters should have default values and how to select good ones."
-   "Write functions that can handle variable numbers of arguments."
-   "Explain what problems can most easily be solved by creating functions with variable numbers of arguments."
-   "Describe four common roles for variables and correctly identify instances of each."
-   "Explain why using variables in stereotyped ways aids comprehension."
-   "Describe four common refactorings and correctly apply each."
keypoints:
-   "The brain thinks every difference is significant, so removing unnecessary differences in formatting reduces cognitive load."
-   "Python software should always conform to the formatting the rules in PEP 8."
-   "Use `name=value` to define a default value for a function parameter."
-   "Use `*args` to define a catch-all parameter for functions taking a variable number of unnamed arguments."
-   "Use `**kwargs` to define a catch-all parameter for functions taking a variable number of named arguments."
-   "Using variables in consistent ways reduces cognitive load."
-   "Common roles for variables include constant, stepper, most-recent holder, most-wanted holder, gatherer, and flag."
-   "Reorganizing code in consistent ways makes errors less likely."
-   "Common refactorings include replacing a value with a name, replacing a repeated test with a flag, extracting a function, and combining functions."
---

> Nothing in software engineering makes sense except in the light of human psychology.
>
> --- Greg Wilson (after [[Dobz1973](#CITE)])

-   Text with *meaningless* **differences** takes longer to read than text without
    because our brains think every difference might be significant
-   Being consistent therefore reduces [cognitive load](#g:cognitive-load),
    which in turn helps us work faster and make fewer errors
-   This lesson explores four kinds of consistency:
    -   How to format program text
    -   What documentation to create and where to put it
    -   How to create and use variables in predictable ways
    -   How to reorganize code systematically when the time comes to make changes
-   Always remember [Orwell's Sixth Rule][orwells-rules]:
    "Break any of these rules sooner than saying anything outright barbarous."

## Standard Python Style {#s:style-pep8}

-   Python has a standard style called [PEP 8][pep-8]
-   And a tool called `pep8` that checks code and reports violations
-   Indent 4 spaces, and always use spaces instead of tabs
-   Do *not* put spaces inside parentheses, i.e., don't use `( 1+2 )`
    -   This applies to function calls as well
-   Always use spaces around comparisons, but use your own judgment for common arithmetic operators
-   Use `ALL_CAPS_WITH_UNDERSCORES` for constants (which should be placed at the top of the file)
-   Use `lower_case_with_underscores` for function and variable names
    -   Only use `CamelCase` for types and classes, which are outside the scope of this lesson
-   Use two blank lines between each function
-   Avoid abbreviations (which can be hard for non-native speakers to understand)
    -   A good programming editor will auto-complete names, so you don't have to do much typing
-   However, short variable names for temporaries and loop variables are OK [[Beni2017](#CITE)]
-   Order within file should be:
    -   Docstring
    -   Imports
    -   Constants
    -   Functions (highest level first)
    -   `if __name__ == '__main__'`
-   A few other rules (some borrowed from [Jenny Bryan][bryan-jenny]'s "[Code Smells and Feels][code-smells-and-feels]")
    -   Do not comment and uncomment sections of code to change behavior
    -   Keep functions short (no more than a page or three levels of control flow)
    -   Put early exits or decisions at the top of the function ([guard clause](#g:guard-clause))
    -   Prefer `if` to `else`

### Exercises

FIXME: exercises

## Default Parameter Values {#s:style-defaults}

FIXME
-   Give users control over everything *and* the ability to ignore details
-   Example: testing tolerance for image comparison
    -   How large a difference in color value to notice?
    -   How many differences above that threshold to tolerate (as percentage)?

```
def image_diff(left, right, per_pixel=0, fraction=0.01):
    ...implementation...
```

-   Default: "any difference counts" and "more than 1% of pixels differ"
    -   But can also be called as `image_diff(old, new, per_pixel=2)` to raise threshold per pixel
    -   Or `image_diff(old, new, fraction=0.05)` to allow more pixels to differ
    -   Or `image_diff(old, new, per_pixel=1, fraction=0.005)` to raise per-pixel threshold but decrease number of allowed differences
-   A subtle trap:

```
def collect(new_value, accumulator=set()):
    accumulator.add(new_value)
    return accumulator
```

-   All calls to `collect` will share the same `accumulator`
    -   Python executes code to define a function
    -   So `set()` is called once as the function is being defined
    -   And `accumulator` refers to *that* set

```
>>> collect('first')
{'first'}
>>> collect('second')
{'first', 'second'}
```

### Exercises

FIXME: exercises

## Variable Numbers of Arguments {#s:style-varargs}

-   Often want functions to be able to accept variable number of arguments (like `print` and `max` do)
-   Can require user to stuff those arguments into a list, e.g., `find_limits([a, b, c, d])`
-   But Python can do this for us
-   Declare a single argument whose name starts with `*`, and Python will put all "extra" arguments into that tuple
    -   By convention, this argument is called `args`

```
def find_limits(*args):
    print(args)
```
```
>>> find_limits(1, 3, 5, 2, 4)
(1, 3, 5, 2, 4)
```

-   This comes after all explicit parameters to avoid ambiguity

```
def select_outside(low, high, *values):
    result = []
    for v in values:
        if (v < low) or (v > high):
            result.add(v)
    return result
```
```
>>> select_outside(0, 1.0, 0.3, -0.2, -0.5, 0.4, 1.7)
[-0.2, -0.5, 1.7]
```

-   Can use the reverse form

```
def trim_value(m, lower, upper):
    print(m, lower, upper)
```
```
>>> saved = ['matrix', 'low', 'high']
>>> trim_value(*saved)
matrix low high
```

-   Parallel forms exist for keyword arguments
    -   Prefix catch-all variable's name with `**`
    -   By convention, variable is called `kwargs`
    -   Catch-all is a dictionary instead of a tuple

```
def settings(user_id, **settings):
    print(user_id, settings)
```
```
>>> settings('jenny', country='CA', lang='R')
jenny {'lang': 'R', 'country': 'CA'}
```

### Exercises

FIXME: exercises

## Roles of Variables {#s:style-roles}

-   [Chunking](#g:chunking) refers to our brain's innate tendency to group things together and remember them as a unit
    -   Chord progressions in music
    -   The murder/background investigation/false suspect/revelation/capture/confession pattern in British murder mysteries
-   Using variables in consistent ways allows us to create and use chunks when reading programs
-   [Design patterns](#g:design-patterns) serve this purpose for larger object-oriented programs
-   The [Roles of Variables][roles-variables] is intended for smaller, non-object programs [[Saja2006](#CITE)]
    -   Names for things you're probably already doing
    -   Makes it easier to communicate
    -   And if you consciously stick to these patterns, others will find your code easier to read as well

-   Fixed Value
    -   Not changed after it is first defined
    -   Some languages allow explicit definition of constants
    -   But note that sometimes a "fixed" value may require executing some code

```
SECONDS_PER_DAY = 24 * 60 * 60
DEFAULT_TEMP_DIR = os.getenv('TMPDIR', '/tmp')
```

-   Stepper
    -   Goes through a succession of values in a predictable way
    -   E.g., the loop variable in a `for` loop or the day of the week

```
DAYS = 'Sun Mon Tue Wed Thu Fri Sat'.split()
for i in range(100):
    day = DAYS[i % len(DAYS)]
```

-   Most-Recent Holder
    -   The value most recently seen
    -   A stepper is a common special case of this
    -   But most-recent holder's value isn't predictable, e.g., the last URL visited

```
record = None
while True:
    record = database.get_record()
    if not record: break
    ...process record...
```

-   Most-Wanted Holder
    -   The "best" value seen so far
    -   E.g., the largest value seen so far in a list, or the record with the highest score

```
def data_range(values):
    if not values: return None, None
    low = high = values[0]
    for v in values:
        low = min(low, v)
        high = max(high, v)
    return low, high
```

-   Gatherer
    -   Often called an accumulator or aggregator, it collects values seen so far in some way
    -   Sum of all values seen to date or list of all positive scores seen to date

```
def acronym(words):
    '''
    acronym(['red', 'green', 'blue']) => 'RGB'
    '''
    result = ''
    for w in words:
        result += w[0].upper()
    return result
```

-   Follower
    -   The value before the current one
    -   E.g., the last-but-one value when calculating the Fibonacci sequence

```
def shift_up(values, follower):
    '''
    shift_up(['a', 'b', 'c'], 'x') => ['x', 'a', 'b']
    '''
    for (i, v) in enumerate(values):
        values[i], follower = follower, values[i]
```

-   One-Way Flag
    -   Changes value once if a condition is seen
    -   E.g., have any negative values been included in this sum?

```
def sum_in_band(values, low, high):
    result = 0
    out_of_band = False
    for v in values:
        if low <= v <= high:
            result += v
        else:
            out_of_band = True
    return result, out_of_band
```

-   Temporary
    -   Holds a value long enough to be used in some calculation and is then discarded
    -   E.g., temporary value for three-way swap (which is unnecessary in Python)
    -   Or intermediate values in large numerical expression

```
def quadratic_roots(a, b, c):
    discriminant = sqrt(b*b - 4*a*c)
    return (-b + discriminant)/(2*a), (-b - discriminant)/(2*a)
```

-   Container
    -   Used to hold values so that they can be processed together
    -   Python calls these "collections"

```
lines = reader.readlines()
...do things with lines...
```

-   Organizer
    -   A temporary used to organize some set of values
    -   E.g., a list that exists just long enough to sort values
    -   An organizer is a temporary container

```
def sort_by_length(names):
    organizer = []
    for n in names:
        organizer.append((len(n), n))
    organizer.sort()
    result = []
    for (length, name) in organizer:
        result.append(name)
    return result
```

-   Note that this is completely unnecessary, since Python allows you to specify a sorting function

### Exercises

FIXME: exercises

## Refactoring {#s:style-refactor}

-   [Refactoring](#g:refactor) is changing the structure of code without changing what it does
    -   Like refactoring an equation
-   Most discussions of refactoring focus on [object-oriented programming](#g:oop)
-   But many patterns can and should be used to clean up [procedural](#g:procedural-programming) code

-   Replace Value With Name

```
# BEFORE
seconds_elapsed = num_days * 24 * 60 * 60
```

```
# AFTER
seconds_elapsed = num_days * SECONDS_PER_DAY
```

-   Easier to understand when read aloud (which is always a good test)
-   Easier to change
    -   You don't think you'll have to, but then people want to use your software on Mars ([Mak2006](#CITE))

-   Replace Repeated Test With Flag
    -   Similar to the above
    -   Remember that Booleans are values and can be assigned

```
# BEFORE
def process_data(data, scaling):
    if len(data) > THRESHOLD:
        scaling = sqrt(scaling)
    ...process data to create score...
    if len(data) > THRESHOLD:
        score = score ** 2
```

```
# AFTER
def process_data(data, scaling):
    is_large_data = len(data) > THRESHOLD
    if is_large_data:
        scaling = sqrt(scaling)
    ...process data to create score...
    if is_large_data:
        score = score ** 2
```

-   Less risk of the tests falling out of sync
-   Clear to reader that the tests are the same
-   Purpose of test is clearer

-   Extract Function

```
# BEFORE
def check_neighbors(grid, point):
    if (0 < point.x) and (point.x < grid.width) and \
       (0 < point.y) and (point.y < grid.height):
        ...look at all four neighbors
```

```
# AFTER
def check_neighbors(grid, point):
    if in_interior(grid, point):
        ...look at all four neighbors...

def in_interior(grid, point):
    ...four tests as above...
```

-   Function might be usable in other contexts
-   But even if not, easier to read aloud (which is a good test of comprehensibility)
-   Use original variable names as parameter names during refactoring to reduce typing

-   Combine Functions

```
# BEFORE
def count_vowels(text):
    num = 0
    for char in text:
        if char in VOWELS:
            num += 1
    return num

def count_consonants(text):
    num = 0
    for char in text:
        if char in CONSONANTS:
            num += 1
    return num
```

```
# AFTER
def count_vowels_and_consonants(text):
    num_vowels = 0
    num_consonants = 0
    for char in text:
        if char in VOWELS:
            num_vowels += 1
        elif char in CONSONANTS:
            num_consonants += 1
    return num_vowels, num_consonants
```

-   Generally done for performance reasons
-   Can make code harder to re-use
    -   For example, assumes that a character is either a vowel or a consonant
    -   Not true of all languages
-   Or people use it and throw some results away

-   Create Lookup Table

```
# BEFORE
def count_vowels_and_consonants(text):
    ...as above...
```

```
# AFTER

IS_VOWEL = {'a' : 1, 'b' : 0, 'c' : 0, ... }
IS_CONSONANT = {'a' : 0, 'b' : 1, 'c' : 1, ... }

def count_vowels_and_consonants(text):
    num_vowels = num_consonants = 0
    for char in text:
        num_vowels += IS_VOWEL[char]
        num_consonants += IS_CONSONANT[char]
    return num_vowels, num_consonants
```

-   Easier to understand and maintain than complicated conditionals
-   [Declarative programming](#g:declarative-programming)

-   Others
    -   Provide Default and Encapsulate Control Flow: forward reference to [s:reuse](#CHAPTER)
    -   Many language features exist to give programmers something to refactor *to*
        -   See a pattern in many contexts
        -   Provide syntactic support for it
        -   Explain in terms of original
    -   Replace Loop With Comprehension is the best example

-   Replace Loop With Comprehension

```
# BEFORE
result = []
for num in values:
    result.append(num * num)
```

```
# AFTER
result = [num * num for num in values]
```

-   Easier to read *for simple calculations*
-   Becomes more complicated to understand with conditionals

```
# BEFORE
result = []
for num in values:
    if num > 0:
        result.append(num * num)
    else:
        result.append(0)
```

```
# AFTER
result = [num * num if num > 0 else 0 for num in values]
```

-   The `else` is necessary so that there's a result for each input
-   Cross-product loops are straightforward

```
# BEFORE
result = []
for left in 'ABC':
    for right in 'xyz':
        result.append(left + right)
```

```
# AFTER
result = [left + right for left in 'ABC' for right in 'xyz']
```

-   What's hard to remember is the equivalent of nested loops where the inner loop depends on the outer
    -   Order in expression feels inverted

```
words = ['first', 'second', 'third']
flattened = [c for w in words for c in w]
```

-   Works for sets, dictionaries, and anything else that can be iterated over
-   This is the direction most modern Python is going, so refactor whenever you can
-   And don't be afraid (at least during development) to create temporaries

```
# BEFORE
for record in data:
    result = []
    score = calculate_score(record)
    if score > THRESHOLD:
        score = THRESHOLD
    result.append(record.ID, score)
```

```
# AFTER
raw = [(d.id, calculate_score(d)) for d in data]
trimmed = [(d.id, THRESHOLD) if d.s > THRESHOLD else (d.id, d.s) for d in raw]
```

### Exercises

FIXME: exercises

## Summary {#s:style-summary}

FIXME: create concept map

{% include links.md %}
