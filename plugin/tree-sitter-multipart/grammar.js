/**
 * @file A parser for multipart/mixed
 * @author Andrew Pikul <ajpikul@gmail.com>
 * @license MIT
 */

/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

module.exports = grammar({
  name: "multipart",

  rules: {
    // TODO: add the actual grammar rules
    source_file: $ => "hello"
  }
});
