## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(yaml12)

## -----------------------------------------------------------------------------
dput(parse_yaml("!some_tag some_value"))

## -----------------------------------------------------------------------------
parse_yaml("! true")
parse_yaml("true")

## -----------------------------------------------------------------------------
handlers <- list(
  "!expr" = function(x) eval(str2lang(x), globalenv())
)
parse_yaml("!expr 1+1", handlers = handlers)

## ----error = TRUE-------------------------------------------------------------
try({
parse_yaml("!expr stop('boom')", handlers = handlers)
})

## -----------------------------------------------------------------------------
handlers <- list(
  "!expr" = function(x) eval(str2lang(x), globalenv()),
  "!upper" = toupper,
  "!lower" = tolower # unused
)

str(parse_yaml(handlers = handlers, "
- !expr 1+1
- !upper r is awesome
- !note this tag has no handler
"))

## -----------------------------------------------------------------------------
handlers <- list(
  "!some_seq_tag" = function(x) {
    stopifnot(identical(x, c("a", "b")))
    "some handled value"
  },
  "!some_map_tag" = function(x) {
    stopifnot(identical(x, list(key1 = 1L, key2 = 2L)))
    "some other handled value"
  }
)

yaml_tagged_containers <- "
- !some_seq_tag [a, b]
- !some_map_tag {key1: 1, key2: 2}
"

str(parse_yaml(yaml_tagged_containers, handlers = handlers))

## -----------------------------------------------------------------------------
eval_yaml_expr_nodes <- function(x) {
  if (is.list(x)) {
    x <- lapply(x, eval_yaml_expr_nodes)
  } else if (identical(attr(x, "yaml_tag", TRUE), "!expr")) {
    x <- eval(str2lang(x), globalenv())
  }
  x
}

safe_loaded <- parse_yaml("!expr 1 + 1")
dput(safe_loaded)
eval_yaml_expr_nodes(safe_loaded)

## -----------------------------------------------------------------------------
dput(parse_yaml("true: true"))

## -----------------------------------------------------------------------------
yaml <- "
true: true
? [a, b]
: tuple
? {x: 1, y: 2}
: map-key
"

str(parse_yaml(yaml))

## -----------------------------------------------------------------------------
handlers <- list(
  "!upper" = toupper,
  "!airport" = function(x) paste0("IATA:", toupper(x))
)

yaml_tagged_key <- "
!upper newyork: !airport jfk
!upper warsaw: !airport waw
"

str(parse_yaml(yaml_tagged_key, handlers = handlers))

## -----------------------------------------------------------------------------
is_bare_string <- \(x) {
  is.character(key) && length(key) == 1L && is.null(attributes(key))
}

eval_yaml_expr_nodes <- function(x) {
  if (is.list(x)) {
    x <- lapply(x, eval_yaml_expr_nodes)

    if (!is.null(keys <- attr(x, "yaml_keys", TRUE))) {
      keys <- lapply(keys, eval_yaml_expr_nodes)
      names(x) <- sapply(
        \(name, key) if (name == "" && is_bare_string(key)) key else name,
        names(x),
        keys
      )
      attr(x, "yaml_keys") <-
        if (all(sapply(keys, is_bare_string))) NULL else keys
    }
  }
  if (identical(attr(x, "yaml_tag", TRUE), "!expr")) {
    x <- eval(str2lang(x), globalenv())
  }

  x
}

## -----------------------------------------------------------------------------
doc_stream <- "
---
doc 1
---
doc 2
"
parse_yaml(doc_stream)
parse_yaml(doc_stream, multi = TRUE)

## -----------------------------------------------------------------------------
write_yaml(list("foo", "bar"))
write_yaml(list("foo", "bar"), multi = TRUE)

## -----------------------------------------------------------------------------
rmd_lines <- c(
  "---",
  "title: Front matter only",
  "params:",
  "  answer: 42",
  "---",
  "# Body that is not YAML"
)
parse_yaml(rmd_lines)

## -----------------------------------------------------------------------------
tagged <- structure("1 + x", yaml_tag = "!expr")
write_yaml(tagged)

## -----------------------------------------------------------------------------
str(parse_yaml("
recycle-me: &anchor-name
  a: b
  c: d

recycled:
  - *anchor-name
  - *anchor-name
"))

## -----------------------------------------------------------------------------
dput(parse_yaml('
%TAG !e! tag:example.com,2024:widgets/
---
item: !e!gizmo foo
'))

## -----------------------------------------------------------------------------
dput(parse_yaml('
%TAG ! tag:example.com,2024:widgets/
---
item: !gizmo foo
'))

## -----------------------------------------------------------------------------
dput(parse_yaml('
%TAG ! tag:example.com,2024:widgets/
---
item: !<gizmo> foo
'))

## -----------------------------------------------------------------------------
'
- foo
- !!str foo
- !<tag:yaml.org,2002:str> foo
' |> parse_yaml() |> dput()

## -----------------------------------------------------------------------------
yaml <- "
- !!timestamp 2025-01-01
- !!timestamp 2025-01-01 21:59:43.10 -5
- !!binary UiBpcyBBd2Vzb21l
"
str(parse_yaml(yaml))

## -----------------------------------------------------------------------------
# Timestamp handler: Convert date-only into Date, otherwise try (some of) the
# YAML 1.1 spec valid timestamp formats as POSIX formats.
# return NA on failure.
timestamp_handler <- function(x) {
  stopifnot(is.character(x), length(x) == 1)
  if (grepl("^\\d{4}-\\d{2}-\\d{2}$", x)) {
    return(as.Date(x))
  }
  formats <- c(
    "%Y-%m-%dT%H:%M:%OS%z",
    "%Y-%m-%d %H:%M:%OS%z",
    "%Y-%m-%dT%H:%M:%OS",
    "%Y-%m-%d %H:%M:%OS",
    "%Y-%m-%d %H:%M"
  )
  as.POSIXct(x, tryFormats = formats, optional = TRUE)
}

# Binary handler: decode Base64 into raw
binary_handler <- function(x) {
  stopifnot(is.character(x), length(x) == 1)
  jsonlite::base64_dec(gsub("[ \n]", "", x))
}

## -----------------------------------------------------------------------------
str(parse_yaml(yaml, handlers = list(
  "tag:yaml.org,2002:timestamp" = timestamp_handler,
  "tag:yaml.org,2002:binary" = binary_handler
)))

