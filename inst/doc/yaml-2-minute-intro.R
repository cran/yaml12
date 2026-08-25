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

## -----------------------------------------------------------------------------
yaml_1_2 <- "
country: NO
enabled: on
port: 22:22
leading_zero: 010
octal: 0o10
release_date: 2026-01-07
"

str(parse_yaml(yaml_1_2))

