---
title: "Logging"
questions:
-   "How should I keep track of what I actually did?"
-   "How can I get my software to report errors?"
objectives:
-   "Explain the advantages of using a logging library rather than `print` statements in data science pipelines."
-   "Describe the intent of the five standard logging levels."
-   "Create and configure a simple logger."
-   "Define a custom format for log messages."
-   "Define a source name to use in consolidated logs."
keypoints:
-   "Use `logging` instead of `print` to report program activity."
-   "Separate  messages into `DEBUG`, `INFO`, `WARNING`, `ERROR`, and `CRITICAL` levels."
-   "Use `logging.basicConfig` to define basic logging parameters."
-   "Always provide timestamps using YYYY-MM-DDTTHH:MM:SS format."
-   "Use standard input and standard output for normal input and output, and send log messages to a file."
-   "Use `tail -f` to monitor log files."
---

Programs should report things that go wrong.
They should also sometimes report things that go right
so that people can monitor their progress
and down the sources of errors.
Adding `print` statements for debugging is a common approach,
but removing them or commenting them out,
only to add them again,
is tedious---especially when the software is in production.

A better approach is to use a [logging framework](#g:logging-framework),
such as Python's `logging` library.
This lets you leave your debugging statements in your code
and turn them on or off at will.
It also lets you send output to any of several destinations,
which is helpful when your data analysis pipeline has several stages
and you're trying to figure out which one contains a bug
(or whether the problem lies in their interaction).
We will start by looking at what kinds of errors you can handle
and how you can detect them,
then go on to look at how logging can make your work more consistent.

## What kinds of errors should I try to handle and what should I do? {#s:logging-kinds}

To start,
we need to distinguish between
[internal errors](#g:internal-error),
such as calling a function with `None` instead of a list.
and [external errors](#g:external-error),
such as trying to read a file that doesn't exist.
Internal errors should be forestalled by unit testing,
but software always encounters new situations in the real world,
and those situations can trigger previously unseen bugs.
Every time one crops up,
we should fix the underlying problem and then write a test to make sure it doesn't creep back into our code.

External errors,
on the other hand,
are usually caused by interactions between the program and the outside world:
for example,
a user may mis-type a filename or the network might be down.
[s:unit-random](#REF) described some ways to write unit tests
to check that software is doing the right thing in these situations,
but we still need to detect them---we'll look at how in the next section.

When an internal error occurs,
the only thing we can do in most cases is report it and halt the program.
If a function has been passed `None` instead of a valid list,
for example,
the odds are good that one of our data structures is corrupted
(or at least in an unexpected state).
We can try to guess what the problem is and take corrective action,
but experience teaches us that our guess will often be wrong
and our attempt to correct the problem might actually make things worse.

Some external errors fall into the same category.
For example,
if our program is trying to fetch data from a web service but is unable to connect to it,
the most sensible thing is probably to report the connection failure.
If we're interacting with a user,
though,
it might make sense for us to prompt them to try again:
it's easy to mis-type a password or select the wrong file for analysis,
and users shouldn't have to re-start the program to correct something like this.

The one rule we should *always* follow is to check for errors as early as possible
so that we don't waste the user's time.
Few things are as frustrating as being told at the end of an hour-long calculation
that the program doesn't have permission to write to an output directory.
It's a little extra work to check things like this up front,
but the larger your program or the longer it runs,
the more useful those checks will be.

## How can I detect errors? {#s:logging-exceptions}

Most modern programming languages use [exceptions](#g:exception) for error handling.
As the name suggests,
an exception is a way to represent an exceptional or unusual occurrence
that doesn't fit neatly into the program's expected operation.
The code below shows a very simple example that reports attempts to divide by zero:

```python
for denom in [-5, 0, 5]:
    try:
        result = 1/denom
        print('1/{} == {}'.format(denom, result))
    except:
        print('{} has no reciprocal'.format(denom))
```
{: title="logging/divide_by_zero.py"}
```text
1/-5 == -0.2
0 has no reciprocal
1/5 == 0.2
```

`try`/`except` looks like `if`/`else` and works in a similar fashion.
If nothing unexpected happens inside the `try` block,
the `except` block isn't run.
If something *does* happen inside the `try`,
the program jumps immediately to the `except`.
This is why the `print` statement inside the `try` doesn't run when `denom` is 0:
as soon as Python tries to calculate `1/denom`,
it skips directly to the error message.

FIXME: diagram

We often want to know what exactly went wrong,
so Python and other languages store information about the error
in an object (also called an exception).
We can [catch](#g:catch) this object and inspect it as follows:

```python
for denom in [-5, 0, 5]:
    try:
        result = 1/denom
        print('1/{} == {}'.format(denom, result))
    except Exception as error:
        print('{} has no reciprocal: {}'.format(denom, error))
```
{: title="logging/catch_exception.py"}
```text
1/-5 == -0.2
0 has no reciprocal: division by zero
1/5 == 0.2
```

We can use any variable name we like instead of `error`;
Python will assign the exception object to that variable
so that we can do things with it in the `except` block.

Python also allows us to specify what kind of exception we want to catch.
For example,
we can write code to handle out-of-range indexing and division by zero separately:

```python
numbers = [-5, 0, 5]
for i in [0, 1, 2, 3]:
    try:
        denom = numbers[i]
        result = 1/denom
        print('1/{} == {}'.format(denom, result))
    except IndexError as error:
        print('index {} out of range'.format(i))
    except ZeroDivisionError as error:
        print('{} has no reciprocal: {}'.format(denom, error))
```
{: title="logging/specific_exceptions.py"}
```text
1/-5 == -0.2
0 has no reciprocal: division by zero
1/5 == 0.2
index 3 out of range
```

Exceptions are organized in a hierarchy:
for example,
`FloatingPointError`, `OverflowError`, and `ZeroDivisionError`
are all special cases of `ArithmeticError`,
so an `except` that catches the latter will catch all three of the former,
but an `except` that catches an `OverflowError`
*won't* catch a `ZeroDivisionError`.
The Python documentation describes all of[the built-in exception types][python-exceptions];
in practice,
the ones that people handle most often are:

-   `ArithmeticError`:
    something has gone wrong in a calculation.
-   `IndexError` and `KeyError`:
    something has gone wrong indexing a list or lookup something up in a dictionary.
-   `OSError`:
    covers cases like a file not being found,
    the program not having permission to read or write it,
    and so on.

So where do exceptions come from?
The answer is that programmers can [raise](#g:raise) them explicitly:

```python
for number in [1, 0, -1]:
    try:
        if number < 0:
            raise ValueError('negative values not supported: {}'.format(number))
        print(number)
    except ValueError as error:
        print('exception: {}'.format(error))
```
{: title="logging/raise_exception.py"}
```text
1
0
exception: negative values not supported: -1
```

We can define our own exception types,
and many libraries do,
but the built-in types are enough to cover common cases.

One final note is that exceptions don't have to be handled where they are raised---in fact,
their greatest strength is that they allow long-range error handling.
If an exception occurs inside a function and there is no `except` for it there,
Python looks in whoever called that function.
It keeps working its way through the [call stack](#g:call-stack)
until it finds a matching `except`;
if there isn't one,
it takes care of the exception itself.

```python
def sum_reciprocals(values):
    result = 0
    for v in values:
        result += 1/v
    return result

numbers = [-1, 0, 1]
try:
    one_over = sum_reciprocals(numbers)
except ArithmeticError as error:
    print('Error trying to sum reciprocals: {}'.format(error))
```
{: title="logging/exception_call_stack.py"}
```text
Error trying to sum reciprocals: division by zero
```

This leasd to the rule "throw low, catch high":
write most of your code without exception handlers,
since there's nothing useful you can do in the middle of a small utility function,
but put a few handlers in the main body of your program
to catch and report all errors.

## What exceptions should I raise and catch? {#s:logging-where}

Broadly speaking there are [two approaches to error handling][lbyl-vs-eafp]:
"look before your leap"
and
"it's easier to ask for forgiveness than permission".
When using the first,
programmers check if an operation will be allowed before trying it:

```python
LOG_DIR = "/tmp/mylogdir"

def write_message(filename, message):
    if os.path.isdir(LOG_DIR):
        path = os.path.join(LOG_DIR, filename)
        with open(path, 'a') as writer:
            writer.write(message)
    else:
        print('No log directory {}'.format(LOG_DIR), file=sys.stderr)
```
{: title="logging/look_before_you_leap.py"}

with the second,
they try the operation
and catch the exception:

```python
LOG_DIR = "/tmp/mylogdir"

def write_message(filename, message):
    try:
        path = os.path.join(LOG_DIR, filename)
        with open(path, 'a') as writer:
            writer.write(message)
    except OSError as error:
        print('Unable to write log message to {}: {}'.format(path, error))
```{: title="logging/ask_permission_not_forgiveness.py"}

The first approach doesn't actually need exception handlers,
except it does:
programmers can never anticipate all of the things that can go wrong in the real world,
so there should always be an `except` somewhere.
Since that's the case,
most programmers prefer the second approach.

When you are raising exceptions yourself,
please make the information as specific as possible.
For example,
suppose a program contains this:

```python
if (val is not None) and (min_val < val < max_val) and (val % 2 == 0) and (val >= prev_val):
    # OK branch
else:
    raise ValueError('Bad value: {}'.format(val))
```

<!-- == noindent -->
Knowing what value caused the error is helpful,
but the message in the exception doesn't tell us why it was bad.
Was it not between `min_val` and `max_val`?
Was it less than `prev_val`?
Whoever has to debug the problem will want to know,
but breaking the test up into cases makes the code harder to read:

```python
if val is None:
    raise ValueError('Value {} is None'.format(val))
elif (val <= min_val) or (max_val <= val):
    raise ValueError('Value {} is out of range ({}, {})'.format(val, min_val, max_val))
elif val % 2 != 0:
    raise ValueError('Value {} is odd'.format(val))
elif val < prev_val:
    raise ValueError('Value {} is not less than previous value {}'.format(val, prev_val))
else:
    # OK branch
```

## How can my program report its activity consistently? {#s:logging-basic}

Suppose you wanted to turn print statements in your program on or off
depending on how much detail you wanted to see.
You might wind up writing code like this:

```python
DEBUG_LEVEL = 2 # or some other number

def complex_function():
    # ...lots of complicated code...
    if (DEBUG_LEVEL > 0):
        print('Everything seems to be going well')
    # ...more complicated code...
    if (DEBUG_LEVEL > 1):
        print('Current alpha value {}'.format(alpha))
```

The value of `DEBUG_LEVEL` acts as a threshold:
any debugging output at a lower level isn't printed.

Logging frameworks combine the `if` and the `print` statements,
and define standard names for the levels.
In order of increasing severity, the levels are:

-   `DEBUG`: very detailed information used for localizing errors.
-   `INFO`: confirmation that things are working as expected.
-   `WARNING`: something unexpected happened, but the program will keep going.
-   `ERROR`: something has gone badly wrong, but the program hasn't hurt anything.
-   `CRITICAL`: potential loss of data, security breach, etc.

Each of these has a corresponding function:
we can use `logging.debug`, `logging.info`, etc. to write messages at these levels.
By default,
only `WARNING` and above are displayed;
messages appear on [standard error](#g:stderr) so that the flow of data in pipes isn't affected.
The source of the message appears as well:
by default, the source is called "root" for reasons that will become clear later.
Thus,
if we run the small program shown below,
only the warning message appears:

```python
import logging

logging.warning('This is a warning.')
logging.info('This is just for information.')
```
{: title="logging/simple_logging.py"}
```text
WARNING:root:This is a warning.
```

## How can I control where log messages go and which log messages appear? {#s:logging-control}

We can configure logging to send messages to a file instead of to standard error
using `logging.basicConfig`.
This has to be done before we make any logging calls: it's not retroactive.
We can use the same function to set the logging level:
everything at or above the specified level is displayed.

```python
import logging

logging.basicConfig(level=logging.DEBUG, filename='everything.log')

logging.debug('This is for debugging.')
logging.info('This is just for information.')
logging.warning('This is a warning.')
logging.error('Something went wrong.')
logging.critical('Something went seriously wrong.')
```
{: title="logging/configure_logging.py"}
```text
DEBUG:root:This is for debugging.
INFO:root:This is just for information.
WARNING:root:This is a warning.
ERROR:root:Something went wrong.
CRITICAL:root:Something went seriously wrong.
```

By default,
`basicConfig` re-opens the log file in [append mode](#g:append-mode);
we can use `filemode='w'` to overwrite the existing log data.
This is useful during debugging,
but we should think twice before doing in production,
since the information we throw away always turns out to have been exactly what we needed to find a bug.

Many programs allow users to specify logging levels and log file names as command-line parameters.
At its simplest,
this is a single flag `-v` or `--verbose` that changes the logging level from `WARNING` (the default)
to `DEBUG` (the noisiest level).
There may also be a corresponding flag `-q` or `--quiet` that changes the level to `ERROR`,
and a flag `-l` or `--logfile` that specifies a log file name
(with standard error being the default for message output).

More sophisticated programs may allow <code>--level <em>name</em><code>,
such as `--level INFO`.
If you don't mind asking users to type in ALL CAPS,
you can have them give a logging level name on the command line
and pass directly to `logging.basicConfig`,
since strings can be used as level names:

```python
basicConfig(level="DEBUG") # the same as basicConfig(level=logging.DEBUG)
```

The flag names `-v`, `--quiet`, and so on are just conventions,
but they are widely used.

> **`tail -f`**
>
> A handy trick during development is to configure logging to send messages to a file,
> and then open another terminal window and run <code>tail -f <em>filename</em></code>
> to display changes to that file as information is appended.
> Doing this gives you a record of the log output
> while allowing you to monitor your program's progress interactively.

## How can I change the format of my log messages? {#s:logging-format}

By default,
`logging` produces messages with the name of the level (such as `WARNING`),
the name of the logger (we have only seen `root` so far)
and the message.
We can put whatever we want in the message,
but `logging` also allows us to specify a [format string](#g:format-string)
using the conventions of an older form of string formatting.
The general form is `%(NAME)s` to insert a named value as a string;
some of the names supported are:

-   `asctime` to get the current time,
-   `levelname` to get the logging level, and
-   `message` to get the message.

As the example below shows,
we can also change the format used for displaying dates.
We should *always* use [ISO date format](#g:iso-date-format):
it is unambiguous,
easy for other programs to parse,
easy to sort:

```python
logging.basicConfig(format='%(asctime)s,%(levelname)s,"%(message)s"', datefmt='%Y-%m-%d:%H:%M:%S')
logging.warning('This is a warning')
```
{: title="logging/message_format.py"}
```text
2019-01-05:06:16:58,WARNING,"This is a warning"
```

Our output looks like readable CSV data:
the date, a comma, the level, another comma, and then the log message in quotes.
This is deliberate:
CSV is the lowest common denominator of data formats,
so logging in that format means that we don't have to write a bunch of regular expressions later
to pull records out of our log.
Remember
if you need to write a parser, you've done something wrong ([s:rules](#REF)).

## How can I handle multiple reporting sources in one program? {#s:logging-source}

Suppose we have a data analysis pipeline with two stages:
one that gets words from files,
and another that counts words.
If we want to log the actions of both,
how will we tell their log messages apart?
We could have each stage write to its own log file.
but then it would be hard to figure out which activities in stage 1
corresponded to activities in stage 2.
If we have them write messages to the same log file,
on the other hand,
how will we know which messages came from which stage?

The answer is that we can configure logging to write to the same output
with different source names.
By default,
the source name is `root` (which we have been seeing so far),
but we can define our own,
and set different levels for different loggers.

Unfortunately,
changing the name of the logging source is the one thing we *can't* easily do with `basicConfig`.
Instead,
we have to:

-   Ask `logging` to create a logger,
-   create a handler to send messages to a file,
-   create a formatter to format those messages, and then
-   stitch them together so that the logger knows about the handler
    and the handler knows about the formatter.

Time to write a function:

```python
import logging

MESSAGE_FORMAT = '%(asctime)s,%(name)s,%(levelname)s,%(message)s'
DATE_FORMAT = '%Y-%m-%dT%H:%M:%S'

def create_logger(name, level, filename):

    # Create logger.
    logger = logging.getLogger(name)
    logger.setLevel(level)

    # Send messages to standard output.
    handler = logging.FileHandler(filename)

    # Define format.
    formatter = logging.Formatter(MESSAGE_FORMAT, DATE_FORMAT)

    # Stitch everything together.
    handler.setFormatter(formatter)
    logger.addHandler(handler)

    return logger
```
{: title="logging/util.py"}

To show how it works,
here is a function that pretends to get words from a file,
sending the words it finds to standard output
and writing log messages at `WARNING` level to `log.csv`
(so the `DEBUG`-level message shouldn't appear):

```python
from util import create_logger

logger = create_logger('get_words', 'WARNING', 'log.csv')

for word in ['first', 'second', 'third']:
    print(word)
    message = 'getting word "{}"'.format(word)
    logger.debug(message)
    logger.warn(message)
    logger.critical(message)
```
{: title="logging/get_words.py"}

And here's another function that counts words it reads from standard input,
writing log messages to the same file at `ERROR` level
(so the `DEBUG` and `WARNING` messages shouldn't appear):

```python
import sys
from util import create_logger

logger = create_logger('count_words', 'ERROR', 'log.csv')

count = 0
for line in sys.stdin:
    count += 1
    message = 'counter {} for {}'.format(count, line.strip())
    logger.debug(message)
    logger.warn(message)
    logger.error(message)
print(count)
```
{: title="logging/count_words.py"}

When we put these to programs in a pipeline,
all we see is the count:

```shell
$ python get_words.py | python count_words.py
3
```

<!-- == noindent -->
but when we look in `log.csv`,
we see the messages from both programs:

```text
2019-01-05T06:43:04,get_words,WARNING,getting word "first"
2019-01-05T06:43:04,get_words,CRITICAL,getting word "first"
2019-01-05T06:43:04,get_words,WARNING,getting word "second"
2019-01-05T06:43:04,get_words,CRITICAL,getting word "second"
2019-01-05T06:43:04,get_words,WARNING,getting word "third"
2019-01-05T06:43:04,get_words,CRITICAL,getting word "third"
2019-01-05T06:43:04,count_words,ERROR,counter 1 for first
2019-01-05T06:43:04,count_words,ERROR,counter 2 for second
2019-01-05T06:43:04,count_words,ERROR,counter 3 for third
```

One of the things this shows,
by the way,
is that Unix doesn't necessarily pass text from program to program one line at a time.
Instead,
it usually [buffers](#g:buffer) input and output.

Libraries like `logging` can send messages to many destinations:
[rotating files](#g:rotating-file) so that the system always has messages from the last few hours
but doesn't fill up the disk,
for example,
or a centralized logging server of some kind that collates logs from many different systems.
You probably don't need any of these,
but the data engineers and system administrators who eventually have to install and maintain your programs
will be very grateful that you used `logging`,
because then they can set it up the way they want with very little work.

## How should I log my program's configuration? {#s:logging-config}

One of the most important things a program can record
is its configuration---its *entire* configuration,
so that its operation can be reproduced exactly later on
([s:configure](#REF)).
Unfortunately,
the configuration for even a moderately complex program consists of many values,
and logging frameworks are designed to log one thing at a time.
This leaves us with some hard choices:

Write the configuration to a separate file.
:   If the program can read configuration files,
    then the configuration written by an old run can be read in directly for a new run.
    However,
    we now have to look in two places to find out what happened in a particular run.

Write the configuration to the log, one value at a time.
:   Some programs write name/value pairs, one per setting, at `INFO` level.
    This puts all the information in one place (the log file),
    but someone now has to write software to get configuration values out of the log
    so that they can be re-used.

Write the configuration to the log as one big string.
:   If the configuration is stored in a configuration object,
    that object can be converted to a JSON string
    and written to the log as one looooong entry.
    This puts all of the information in one place,
    and it's relatively easy to recover,
    but the log entry isn't particularly readable.

Use a structured log instead of a line-oriented log.
:   Most log files are written line-by-line because lines of text are the universal language of Unix pipelines.
    Some people are now experimenting with logs that use more structured storage formats,
    and if everything in the log is JSON anyway,
    writing the configuration as a blob of JSON is straightforward.

On balance,
we recommend the third option:
convert the configuration to a JSON structure and write that as a single log entry.

## Summary {#s:logging-summary}

FIXME: create concept map for logging

## Exercises {#s:logging-exercises}

<section markdown="1">
### Set the logging level

-   FIXME: use `getopt` and `--level NAME` to set logging level.
</section>

<section markdown="1">
### Display logging configuration

-   FIXME: use `logging_tree.printout()` to display logging configuration.
</section>

<section markdown="1">
### Log to standard error as well as a file

-   FIXME: modify `create_logger` to log to standard error as well as to a file.
</section>

<section markdown="1">
### Write configuration as JSON

-   FIXME: write configuration as JSON.
</section>

{% include links.md %}
