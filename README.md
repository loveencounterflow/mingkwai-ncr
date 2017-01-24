<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [MingKwai-NCR](#mingkwai-ncr)
  - [Usage](#usage)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# MingKwai-NCR

A derivative of [NCR](https://github.com/loveencounterflow/ncr.git) with extra data for CJK
character processing and typesetting.

## Usage

**Note**—This module is intended to be used as is customary with NodeJS / npm modules, i.e. using
`require`:

```coffee
MKNCR = require 'mingkwai-ncr'
```

There are a few points to keep in mind:

* `mingkwai-ncr` only works properly in tandem with `jizura-datasources` and `mojikura` (the Jizura DB
  feeder);

* those modules are expected to be found within the same
  ['rack'](https://github.com/loveencounterflow/mingkwai-rack) folder as `mingkwai-ncr` itself;

* `mingkwai-ncr/data/isl-entries.json` contains a cached version of the data that is to be organized into
  an [interval skip list](https://github.com/loveencounterflow/interskiplist) for efficient per-codepoint
  retrieval;

* when any data source files are found to be newer than the cache at the point in time when `mingkwai-ncr`
  is `require`d from another module, an exception with a helpful error message will be raised; depending
  on your current location in the file tree, that message might read

  ```
  cache file
  data/isl-entries.json
  is out of date
  run the command
  node lib/main.js
  to rebuild data/isl-entries.json
  ```

  You can then run `node lib/main.js` (that is, tell NodeJS to run `mingkwai-ncr/lib/main.js` as
  a script) to rebuild the cache.

  I see no way to make the cache-rebuilding step fully transparent; this is because `require 'x'` is a
  synchronous call, but rebuilding the cache is inherently asynchronous.


<!--

API Usage over currently active projects:

   2 as_chr
   2 as_csg
   2 as_sfncr
   3 analyze
   3 as_rsg
   3 chr_from_cid_and_csg
   4 jzr_as_uchr
   5 normalize_to_pua
   6 as_cid
  13 as_fncr
  16 as_uchr
  27 is_inner_glyph
  33 chrs_from_text


 -->
