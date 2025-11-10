package tree_sitter_multipart_test

import (
	"testing"

	tree_sitter "github.com/tree-sitter/go-tree-sitter"
	tree_sitter_multipart "www.github.com/geopozo/neovim-collection/bindings/go"
)

func TestCanLoadGrammar(t *testing.T) {
	language := tree_sitter.NewLanguage(tree_sitter_multipart.Language())
	if language == nil {
		t.Errorf("Error loading Multipart grammar")
	}
}
