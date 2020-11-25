# 2020-03-13 - [DRAFT] when to tag a new release on the CNF Conformance repo

## How to create a tagged release

See https://help.github.com/en/github/administering-a-repository/managing-releases-in-a-repository#creating-a-release

## When to create a new tagged release


**[PATCH] Releases for backwards compatible bug fixes and updates to existing tests**
- bug fixes or trivial update to existing test
- 1 or more updated tests are merged to master
- all automated integration/spec coverage passes
- usage documentation updated, if usage changed for test
- new test is marked as GA :heavy_check_mark: 
- tag with new patch version vMAJOR.MINOR.PATCH_VERSION, eg. v0.4.2

_Note: this covers both workload (ie. application) and platform tests_

**Releases for PoC and Beta tests**
- No tagged releases for PoC and beta level tests

**[MINOR] Releases for new tests, which do not break existing usage**
- new test is moving to GA status. (could be brand new or moved from PoC to GA)
- 1 or more tests are merged to master
- new test(s) have automated integration/spec coverage
- all automated integration/spec coverage passes
- all new tests have working usage documentation
- new test is marked as GA :heavy_check_mark: 
- tag with new minor version vMAJOR.MINOR_VERSION.PATCH, eg. v0.4.0

_Note: this covers both workload (ie. application) and platform tests_


**[MINOR] Releases for new, non-breaking environment feature (eg. adding Kind support)**
- Add new, non-breaking, feature to the environment (eg. adding Kind support)
- all automated integration/spec coverage passes
- documentation updated covering the environment updates
- tag with new minor version vMAJOR.MINOR_VERSION.PATCH, eg. v0.5.0


**[MAJOR] Releases for changes which break existing usage**
- Change which breaks backwards compatibility with existing usage
- Change merged to `master`
- All automated integration/spec coverage passes
- Change is fully documented for anything affected
- Tag with new major version vMAJOR_VERSION.MINOR.PATCH, eg. v2.0.0

_Note: this covers both workload (ie. application) and platform tests_

**[Automated releases]**
- Create a tag off of the master branch 
```
git tag -a 'vMAJOR.MINOR.PATCH' -m "vMAJOR.MINOR.PATCH Release" 
git push --tags 
```
- Wait for github actions to complete the build
- Go to https://github.com/cncf/cnf-conformance/releases
- Locate the draft release for the build
- Modify the release notes to reflect the contents for the release
- Mark the release as non-draft 


**[Manually create builds]**
based on [INSTALL.md#optional-build-binary](https://github.com/cncf/cnf-conformance/blob/master/INSTALL.md#optional-build-binary) and [Minimal instructions to run the tests from source (as of 2020-06-23)](https://hackmd.io/hcHoJEKaRWuyf_fZ7ITxLw)
- Download source: `git clone https://github.com/cncf/cnf-conformance.git`
- `cd cnf-conformance`
- Install dependencies: `shards install`
- Create a static binary: `crystal build src/cnf-conformance.cr --release --static --link-flags "-lxml2 -llzma"`
