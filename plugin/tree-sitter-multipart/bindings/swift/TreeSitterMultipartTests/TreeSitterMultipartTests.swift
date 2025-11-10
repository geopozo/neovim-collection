import XCTest
import SwiftTreeSitter
import TreeSitterMultipart

final class TreeSitterMultipartTests: XCTestCase {
    func testCanLoadGrammar() throws {
        let parser = Parser()
        let language = Language(language: tree_sitter_multipart())
        XCTAssertNoThrow(try parser.setLanguage(language),
                         "Error loading Multipart grammar")
    }
}
