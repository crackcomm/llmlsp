# Contributing guidelines

## Introduction

A well-crafted commit message is the best way to communicate the purpose of a change to the rest of your team. By following a consistent format and providing enough context, you can make it easier for others to understand what you have done and why.

One popular way of writing commit messages is to use [semantic commit messages](https://gist.github.com/joshbuchea/6f47e86d2510bce28f8e7f42ae84c716), which follow a specific format and include a type and a subject. The type describes the kind of change that was made, and the subject provides a brief summary of the change in present tense.

### Format

The general format for a semantic commit message is:

```
<type>(<scope>): <subject>
```

where `<type>` is the type of change, `<scope>` is an optional description of the affected area of the code, and `<subject>` is a brief summary of the change in present tense.

- `type`: The type of the change being made (see above).
- `scope`: The library or change path affected by the change (optional).
- `subject`: A brief summary of the change in present tense.

Here are some examples of well-formed commit messages:

```
feat(library_name): add hat wobble
fix(search): fix search query parsing
docs: update installation instructions
style: format code according to style guide
refactor: extract method foo
test: add missing unit tests for method foo
chore: update build script
```

Note that the `scope` field is optional, and can be omitted if not applicable. For example:

```
feat: add hat wobble
fix: fix search query parsing
```

### Types

Commit messages should begin with a type that describes the change being made. The following types are recommended:

- **feat**: A new feature for the user, not a new feature for the build script.
- **fix**: A bug fix for the user, not a fix to a build script.
- **docs**: Changes to the documentation.
- **style**: Formatting, missing semi-colons, etc; no production code change.
- **refactor**: Refactoring production code, e.g. renaming a variable.
- **test**: Adding missing tests, refactoring tests; no production code change.
- **chore**: Updating build tasks, etc; no production code change.
- **build**: changes to the build process or build scripts
- **ci**: changes to continuous integration scripts and configuration
- **perf**: changes that improve performance
- **security**: changes that improve security
- **dependency**: updates to project dependencies
- **revert**: reverts a previous commit
- **config**: changes to configuration files

## Formatting and linting

Code should be formatted to the standard.

- OCaml uses ocamlformat.
- C++ uses clang-format.
- Python uses black.
- Bazel build rules use buildifier.
- Go uses gofmt.
