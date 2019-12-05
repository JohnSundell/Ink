# Benchmarking

There are several ways to test and benchmark Ink in addition to the tests implemented in the InkTests target. Generally, these can be divided into two categories:

1. Running the testing and benchmarking scripts included in the [commonmark-spec]() and [Cmark]() repositories.
2. Using the [raw test data]() from the CommonMark spec to generate additional XCTest classes and methods.

The primary motivation for using these additional tests is to find areas where Ink could incorporate common Markdown features that are currently unimplemented.

## Advantages & Disadvantages

There are advantages and disadvantages to both methods.

### External CommonMark/Cmark scripts

#### Advantages

* Easy to set up and run, without adding dependencies.
* Provides external validation and corner case testing for many already-implemented features.
* Gives a good broad level overview of which features Ink could improve or add.
* Includes some HTML normalization, reducing the number of tests which fail despite equivalent HTML.

#### Disadvantages

* Requires shell scripting if results need to be transformed for better visualization.
* Very little control over built-in HTML normalization, so some tests still fail on equivalent HTML.

### Native XCTest classes

#### Advantages

* Integrated tests can be run easily with `swift test` or in Xcode.
* When adding new features, newly passing tests can be easily copied to the InkTests target.

#### Disadvantages

* Requires writing a tool to generate XCTest classes from the CommonMark spec json.
* Requires handling HTML normalization, either by dependency or by writing a normalizer.

## Preparation

First, you should have downloaded and installed the CLI tool. These tests rely on the improved CLI tool introduced in PR #19.

```
git clone https://github.com/JohnSundell/Ink.git
cd Ink
make
```

If you want to perform testing/benchmarking on cmark, you will also need to build or install it. I installed using Homebrew:

```
brew install cmark
```

Note: I tried the default `apt` package on Ubuntu 18.04, and it appears to be outdated, as quite a few tests failed the spec test suite.

## Instructions

### CommonMark spec tests

To test the currently installed Ink binary:

```
git clone https://github.com/commonmark/commonmark-spec.git
cd commonmark-spec
git checkout 0.29
python3 test/spec_tests.py -p="$(which ink)"
```

(The checkout of version 0.29 is because the master branch currently has an additional test that is not yet in the spec, and which even cmark fails.)

To test cmark, use the following command:

```
python3 test/spec_tests.py -p="$(which cmark) --unsafe"
```

(The `--unsafe` flag is there because otherwise cmark replaces some raw HTML with a comment, leading to failing tests).

A bash script which displays the tests broken up into categories (should be run from within the commonmark-spec directory):

```
#!/bin/bash

sections="$(python3 test/spec_tests.py --dump-tests | grep section | uniq | cut -f 2 -d ':' | sed -e 's/^ "//' -e 's/"$//')"

echo "$sections" | while read section; do
  echo "Section: $section"
  python3 test/spec_tests.py -p "$(which ink)" -P "$section" | tail -1 | cut -d ' ' -f 1-6 | sed -e 's/^/   /' -e 's/,$//'
done
```

If you want to get the tests in JSON format, 

```
python3 test/spec_tests.py --dump-tests
```

### cmark performance tests

To benchmark the currently installed Ink binary:

```
git clone https://github.com/commonmark/cmark.git
cd cmark
make bench PROG="$(which ink)"
```

(Be patient, as this will likely take over a minute, as it runs ten times and averages the result.)

To test cmark, use the following command:

```
make bench PROG="$(which cmark) --unsafe"
```

### XCTest generation

There are at least two active community approaches to generating XCTest classes:

#### [commonmark-xctests](https://github.com/john-mueller/Ink/tree/commonmark-xctests) branch on the [john-mueller/Ink]() fork  

Branch includes both a generator which creates static .swift files in the Tests directory, and the generated files themselves. You shouldn't need to regenerate the test files unless you've made changes or want to see how it works.

To test:

```
git clone https://github.com/john-mueller/Ink --branch commonmark-xctests
cd Ink
swift test
```

To generate:

```
swift run CMTestGenerator
```

This branch will stay up to date, but is not intended to be merged, as it adds a dependency on [SwiftSoup](https://github.com/scinfu/SwiftSoup) and adds a new executable target to `Package.swift`, which are outside the scope of Ink's design.

#### <https://github.com/steve-h/InkTesting>

See [README.md](https://github.com/steve-h/InkTesting/blob/master/README.md) for explanation.
