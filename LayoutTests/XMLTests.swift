//  Copyright © 2017 Schibsted. All rights reserved.

import XCTest
@testable import Layout

class XMLTests: XCTestCase {

    // MARK: Malformed XML

    func testViewInsideHTML() {
        let input = "<p><UIView/></p>"
        XCTAssertThrowsError(try Layout(xmlData: input.data(using: .utf8)!)) { error in
            XCTAssert("\(error)".contains("p"))
        }
    }

    func testViewInsideHTMLInsideLabel() {
        let input = "<UILabel><p><UIView/></p></UILabel>"
        XCTAssertThrowsError(try Layout(xmlData: input.data(using: .utf8)!)) { error in
            guard let layoutError = error as? LayoutError else {
                XCTFail("\(error)")
                return
            }
            XCTAssertTrue("\(layoutError)".contains("Unsupported HTML"))
            XCTAssertTrue("\(layoutError)".contains("UIView"))
        }
    }

    func testInvalidHTML() {
        let input = "<UILabel>Some <bold>bold</bold> text</UILabel>"
        let xmlData = input.data(using: .utf8)!
        XCTAssertThrowsError(try Layout(xmlData: xmlData)) { error in
            XCTAssert("\(error)".contains("bold"))
        }
    }

    // MARK: Encoding

    func testEncodeXMLEntities() {
        let input = "if 2 > 3 && 1 < 4"
        let expected = "if 2 > 3 &amp;&amp; 1 &lt; 4"
        XCTAssertEqual(input.xmlEncoded(), expected)
    }

    // MARK: HTML

    func testNoEncodeHTMLEntitiesInText() {
        let text = "2 legs are < 4 legs"
        let input = "<UILabel>\(text.xmlEncoded())</UILabel>"
        let xmlData = input.data(using: .utf8)!
        let layout = try! Layout(xmlData: xmlData)
        XCTAssertEqual(layout.expressions["text"], text)
    }

    func testEncodeHTMLEntitiesInHTML() {
        let html = "2 legs are &lt; 4 legs<br/>"
        let input = "<UILabel>\(html)</UILabel>"
        let xmlData = input.data(using: .utf8)!
        let layout = try! Layout(xmlData: xmlData)
        XCTAssertEqual(layout.expressions["attributedText"], html)
    }

    func testEncodeHTMLEntitiesInHTML2() {
        let html = "<p>2 legs are &lt; 4 legs</p>"
        let input = "<UILabel>\(html)</UILabel>"
        let xmlData = input.data(using: .utf8)!
        let layout = try! Layout(xmlData: xmlData)
        XCTAssertEqual(layout.expressions["attributedText"], html)
    }
}
