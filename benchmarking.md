# Benchmarking

This document is not necessarily intended to be merged as-is (although it may be good to include a cleaned up version as documentation in case others are interesting in benchmarking when contributing to the project). Instead, it is intended to start a conversation about two important benchmarks—the CommonMark spec compatibility suite and the cmark performance benchmark—and how they can be integrated into the Ink testing suite.

## Motivation

There are several advantages of using these benchmarks in addition to the XCTest suite:

* Easy to set up and run, without adding dependencies
* Provides external validation and corner case testing, which would take a while to generate by ourselves
* Gives some indication of CommonMark features that are not yet implemented in Ink, for those who are interested in improving conformance

## Preparation

First, you should have downloaded and installed the CLI tool. These tests rely on the improved CLI tool introduced in #19.

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

### CommonMark spec conformance tests

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
  sectiontext="$section"
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

## Automation

The next step might be to integrate these into CI so that we catch performance/conformance regressions. I don't have experience in that area, but I'm willing to jump in and learn. It seems like the only thing we would need is python3 and git.

Presumably we'd want to have it run the benchmark against master and against the PR branch, to compare and identify regressions.

Here's an example script that I've been using. This could probably be cleaned up, but serves as a proof of concept.

```
#!/bin/bash

baseversion="$1"
newversion="$2"

rm -rf Ink commonmark-spec
git clone https://github.com/JohnSundell/Ink.git
git clone https://github.com/commonmark/commonmark-spec.git

cd Ink
git checkout "$baseversion"
# pull in new CLI on old commits
git checkout master Sources/InkCLI
swift build -c release

cd ../commonmark-spec
git checkout 0.29
baseoutput="$(python3 test/spec_tests.py -p="../Ink/.build/release/ink-cli")"
baseresults="$(echo "$baseoutput" | tail -1)"

cd ../Ink
git checkout "$newversion"
# pull in new CLI on old commits
git checkout master Sources/InkCLI
swift build -c release

cd ../commonmark-spec
newoutput="$(python3 test/spec_tests.py -p="../Ink/.build/release/ink-cli")"
newresults="$(echo "$newoutput" | tail -1)"

echo $'\n'"$baseversion: $baseresults"$'\n'"$newversion: $newresults"

difference="$(diff -u <(echo "$baseoutput" | grep Example | cut -f2 -d' ') <(echo "$newoutput" | grep Example | cut -f2 -d' '))"

deletions="$(echo "$difference" | grep -E '^\-\d')"
additions="$(echo "$difference" | grep -E '^\+\d')"
newpassingcount="$(echo "$deletions" | grep -c '-')"
newfailingcount="$(echo "$additions" | grep -c '+')"
newpassingtests="$(echo "$deletions" | sed -E 's/^\-//' | tr '\n' ' ')"
newfailingtests="$(echo "$additions" | sed -E 's/^\+//' | tr '\n' ' ')"

echo "$newpassingcount newly passing tests: $newpassingtests"
echo "$newfailingcount newly failing tests: $newfailingtests"
```

Calling `./commonmark-tests.bash 0.1.2 0.1.3` ends with the following output:

```
> 0.1.2: 191 passed, 458 failed, 0 errored, 0 skipped
> 0.1.3: 200 passed, 449 failed, 0 errored, 0 skipped
> 11 newly passing tests: 41 42 43 235 236 237 238 266 271 272 536 
> 2 newly failing tests: 45 46 
```

## XCTest

There also exists the possibility that we could do performance/conformance testing using XCTest. In fact, I am aware of at least two experiments in this direction (and my own experiments):

* <https://gist.github.com/ezfe/05ff86cb42ecdffcb9cc22f47664d4f7>
* <https://github.com/steve-h/Ink/tree/commonmarktests>

Upsides:

* Integration with Xcode
* Presumably simpler CI integration (as we're already running XCTests through Bitrise)

Downsides:

* Would require maintenance of a separate tool to generate the tests based on the CommonMark spec.json
* HTML output would need to be normalized, otherwise you get errant failures.
* This means either taking on a dependency or writing/testing our own HTML normalizer.
* Increases test time by a significant margin
* Would require leaving out/commenting out failing tests so that CI can continue to check for regressions until those features are implemented

Basically, I think that it's too early to try and put CommonMark compatibility tests for *unimplemented* features in XCTest. Individual tests should continue to be added to the XCTest suite as improvements and bugfixes are made.