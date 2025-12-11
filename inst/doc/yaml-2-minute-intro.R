## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(yaml12)

## ----echo = FALSE-------------------------------------------------------------
first_example <- '
title: A Modern YAML parser written in Rust
properties: [correct, safe, fast, simple]
score: 9.5
categories:
  - yaml
  - r
  - example
settings:
  simplify: true
  note: >
    This is a folded block
    that turns line breaks
    into spaces.
  note_literal: |
    This is a literal block
    that keeps
    line breaks.
'

## -----------------------------------------------------------------------------
str(parse_yaml(first_example))

