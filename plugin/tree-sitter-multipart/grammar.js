/**
 * @file A parser for multipart/mixed
 * @author Andrew Pikul <ajpikul@gmail.com>
 * @license MIT
 */

/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

module.exports = grammar({
  name: 'multipart',

  rules: {
    document: $ => seq(
      repeat($.part),
      $.final_boundary
    ),

    part: $ => seq(
      $.boundary_line,
      optional($.headers),
      optional($.body)
    ),

    boundary_line: _ => token(seq('--BOUNDARY', /\r?\n/)),

    final_boundary: _ => token(seq('--BOUNDARY--', /\r?\n?/)),

    header_name: _ => /[A-Za-z0-9\-]+/,
    header_value: _ => /[^\r\n]+/,
    header: $ => seq(
      field('name', $.header_name),
      ':',
      field('value', $.header_value),
      /\r?\n/
    ),

    headers: $ => seq(repeat1($.header), /\r?\n/),

    // Body is everything until next boundary line
    body: _ => token(/[\s\S]*?(?=^--BOUNDARY(?:--)?\r?\n?)/m),
  }
});
