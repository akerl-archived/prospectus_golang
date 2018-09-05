prospectus_golang
=========

[![Gem Version](https://img.shields.io/gem/v/prospectus_golang.svg)](https://rubygems.org/gems/prospectus_golang)
[![Build Status](https://img.shields.io/travis/com/akerl/prospectus_golang.svg)](https://travis-ci.com/akerl/prospectus_golang)
[![Coverage Status](https://img.shields.io/codecov/c/github/akerl/prospectus_golang.svg)](https://codecov.io/github/akerl/prospectus_golang)
[![Code Quality](https://img.shields.io/codacy/3e438ed62cec4ceaa4cca42cb567e42e.svg)](https://www.codacy.com/app/akerl/prospectus_golang)
[![MIT Licensed](https://img.shields.io/badge/license-MIT-green.svg)](https://tldrlegal.com/license/mit-license)

[Prospectus](https://github.com/akerl/prospectus) helpers for checking Golang dependency status.

## Usage

Add the following 2 lines to the .prospectus:

```
## Add this at the top
Prospectus.extra_dep('file', 'prospectus_golang')

## Add this inside your item that has a gemspec
extend ProspectusGolang::Deps.new
```

## Installation

    gem install prospectus_golang

## License

prospectus_golang is released under the MIT License. See the bundled LICENSE file for details.

