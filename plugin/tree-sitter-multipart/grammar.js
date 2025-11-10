/**
 * @file A parser for multipart/mixed
 * @author Andrew Pikul <ajpikul@gmail.com>
 * @license MIT
 */

/// <reference types="tree-sitter-cli/dsl" />
// @ts-check


module.exports = grammar({
  name: 'multipart',

  extras: $ => [],

  rules: {
    document: $ => seq(
      repeat($.part),
      $.final_boundary
    ),

    part: $ => seq(
      $.boundary_line,
      $.headers,
      optional($.body)
    ),

    // Exact, no whitespace or variants
    boundary_line: _ => token(/--BOUNDRY\r?\n/),
    final_boundary: _ => token(/--BOUNDRY--\r?\n?/),

    _eol: _ => /\r?\n/,

    header_name: _ => /[A-Za-z0-9\-]+/,
    header_value: _ => /[^\r\n]+/,
    header: $ => seq(
      field('name', $.header_name),
      ':',
      field('value', $.header_value),
      $._eol
    ),

    headers: $ => seq(repeat1($.header), $._eol),

    // Body = sequence of lines that are not boundaries.
    // No look-arounds; Tree-sitter will stop this rule when it sees a boundary token.
    body: $ => repeat1($.body_line),

    // Just any line with content (Tree-sitter stops before next boundary token)
    body_line: _ => token(prec(-1, /[^\r\n]*(\r?\n)?/)),
  }
});
