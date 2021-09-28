# `argparse`

Positional and optional argument parsing.

## Introduction

```python
import argparse

parser = argparse.ArgumentParser()

# Positional arguments.
parser.add_argument('positional')

# Optional arguments.
parser.add_argument('--optional', action='store_true'

args = parser.parse_args(['value1', '--optional'])

print(args.positional)
print(args.optional)
```


## `ArgumentParser`

* `prog`: Name of program (default: sys.argv[0])
* `usage`: (default: generated from arguments added to parser)
* `description`:
* `epilog`: Text to display after the argument help (default: none)
* `formatter_class`: A class for customizing the help output

* `parents`: A list of ArgumentParser objects whose arguments should also be
  included

* `prefix_chars`: The set of characters that prefix optional arguments
  (default: ‘-‘)
* `fromfile_prefix_chars`: The set of characters that prefix files from which
  additional arguments should be read (default: None)

* `argument_default`: The global default value for arguments (default: None)

* `add_help`: Add a -h/--help option to the parser (default: True)
* `allow_abbrev`: Allows long options to be abbreviated if the abbreviation is
  unambiguous. (default: True)
* `exit_on_error`: Determines whether or not ArgumentParser exits with error
  info when an error occurs.
* `conflict_handler`: The strategy for resolving conflicting optionals (usually
  unnecessary)


## `add_argument`

* `name` or `flags`: Either a name or a list of option strings
  - positional: `add_argument('name')`    --> `Namespace(name=value)`.
  - optional: `add_argument('-f, --foo')` --> `Namespace(foo=value)`.
* `help`: A brief description of what the argument does.
    `help='A useful help  for %(prog)s (default: %(default)s)'`
* `metavar`: A name for the argument in usage messages.
  `usage:  [-h] [--foo FOO] bar`
  `usage:  [-h] [--foo YYY] XXX`

* `dest`: Variable name. Usually inferred from `name`. `--foo-bar` becomes
   `foo_bar`
* `required`: Whether or not the command-line option may be omitted (optionals
  only).
* `nargs`: The number of command-line arguments that should be consumed.
  - `'2'`: 2 argumets consumed.
  - `'?'`: 1 or 0 arguments consumed. If 0, `default` or `const` used.
  - `'*'`: 0 or more arguments into a list.
  - `'+'`: 1 or more arguments into a list.
* `const`: A constant value required by some action and nargs selections.
  - `action='store_const'`
  - `action='append_const'`
  - `nargs='?'`
* `default`: The value produced if the argument is absent from the command line
  and if it is absent from the namespace object.
* `choices`: A container of the allowable values for the argument.

* `type`: The type to which the command-line argument should be converted.

  Built-in types:
  - `add_argument('count', type=int)`
  - `add_argument('distance', type=float)`
  - `add_argument('street', type=ascii)`
  - `add_argument('code_point', type=ord)`
  - `add_argument('source_file', type=open)`
  - `add_argument('dest_file', type=argparse.FileType('w', encoding='latin-1'))`
  - `add_argument('datapath', type=pathlib.Path)`

  Custom types:
  ```python
  >>> def hyphenated(string):
  ...     return '-'.join(string.split()])
  >>> parser.add_argument('phrase', type=hyphenated)
  >>> parser.parse_args('A simple phrase')
  Namespace(title='A-simple-phrase)
  ```

* `action`: The basic type of action to be taken when this argument is
  encountered at the command line.
  - `store`: default
  - `store_const`: expects the `const=42` parameter.
  - `store_true` `store_false`
  - `append`: `--foo 42 --foo 69` -> `Namespace(foo=['42', '69'])`
  - `append_const`: `--foo --foo --foo` -> `Namespace(foo=['42', '42', '42'])`
  - `count`: `-vvv` -> `Namespace(verbose=3)`
  - `help`: Why use this? Generate the help text.
  - `version`: Expects `version=0.1.0` argument.
  - `extend`: `--foo 42 --foo 1 2 3` -> `Namespace(foo=[42, 1, 2, 3])`
  - `argparse.BooleanOptionalAction`: `--foo`, `--no-foo`


## Action Classes

```python
>>> class FooAction(argparse.Action):
...     def __init__(self, option_strings, dest, nargs=None, **kwargs):
...         if nargs is not None:
...             raise ValueError("nargs not allowed")
...         super().__init__(option_strings, dest, **kwargs)
...     def __call__(self, parser, namespace, values, option_string=None):
...         print('%r %r %r' % (namespace, values, option_string))
...         setattr(namespace, self.dest, values)
...
>>> parser = argparse.ArgumentParser()
>>> parser.add_argument('--foo', action=FooAction)
>>> parser.add_argument('bar', action=FooAction)
>>> args = parser.parse_args('1 --foo 2'.split())
Namespace(bar=None, foo=None) '1' None
Namespace(bar='1', foo=None) '2' '--foo'
>>> args
Namespace(bar='1', foo='2')
```

## `parser.parse_args(args=None, namespace=None)`

* `args`: default is `sys.argv`
* `namespace`: Possible to provide an existing namespace to operate on.

Valid ways of defining optional parameters:
* `['--foo', 'FOO']`
* `['--foo=FOO']`
* `['-xX']` -> `Namespace(x='X')`
* `['-xyzZ']` -> `Namespace(x=True, y=True, z='Z')`

Using negative numbers as an argument name introduces complications.


## Namespace object

```python
>>> ns = Namespace(foo='Foo', bar='Bar')`
>>> vars(ns)
{'foo': 'Foo', 'bar': 'Bar'}
>>> ns.foo
'Foo'
```

## Subparsers

```
>>> parser = argparse.ArgumentParser()      # ArgumentParser
>>> subparsers = parser.add_subparsers()    # _SubParsersAction
>>> parser_a = subparsers.add_parser('a')   # ArgumentParser
>>> parser_a.add_argument('--foo')
>>> parser.parse_args(['a', '--foo', 'FOO')
Namespace(foo='FOO')
```

