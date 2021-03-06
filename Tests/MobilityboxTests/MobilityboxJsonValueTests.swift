//
//  JsonValueTests.swift
//  
//
//  Created by René Meye on 09.06.22.
//

import XCTest
@testable import Mobilitybox

class MobilityboxJsonValueTests: XCTestCase {
    
    // MARK: - gpa (computed property)
    
    /// Arrays with Strings are parsed.
    func testDecodingSimpleArray() {
        let result = try? JSONDecoder().decode(MobilityboxJSONValue.self, from: "[\"Hallo Welt\"]".data(using: .utf8)!)
        XCTAssertEqual(result?.array?[0].string, "Hallo Welt")
    }
    
    /// Objects with Strings are parsed.
    func testDecodingSimpleObject() {
        let result = try? JSONDecoder().decode(MobilityboxJSONValue.self, from: "{\"Hallo\": \"Welt\"}".data(using: .utf8)!)
        XCTAssertEqual(result?.dictionary?["Hallo"]?.string, "Welt")
    }
    
    /// Objects with Integers are parsed.
    func testDecodingSimpleObjectWithInteger() {
        let result = try? JSONDecoder().decode(MobilityboxJSONValue.self, from: "{\"answer\": 42}".data(using: .utf8)!)
        XCTAssertEqual(result?.dictionary?["answer"]?.double, 42)
    }
    
    /// Objects with Booleans are parsed.
    func testDecodingSimpleObjectWithBool() {
        let result = try? JSONDecoder().decode(MobilityboxJSONValue.self, from: "{\"answer\": true}".data(using: .utf8)!)
        XCTAssertEqual(result?.dictionary?["answer"]?.bool, true)
    }
    
    func testDecodingSimpleObjectWithBoolFalse() {
        let result = try? JSONDecoder().decode(MobilityboxJSONValue.self, from: "{\"answer\": false}".data(using: .utf8)!)
        XCTAssertEqual(result?.dictionary?["answer"]?.bool, false)
    }
    
    /// Objects with Nil are parsed.
    func testDecodingSimpleObjectWithNil() {
        let result = try? JSONDecoder().decode(MobilityboxJSONValue.self, from: "{\"answer\": null}".data(using: .utf8)!)
        XCTAssertEqual(result?.dictionary?["answer"]?.isNil, true)
    }
    
    /// Objects with Doubles are parsed.
    func testDecodingSimpleObjectWithDouble() {
        let result = try? JSONDecoder().decode(MobilityboxJSONValue.self, from: "{\"answer\": 42.23}".data(using: .utf8)!)
        XCTAssertEqual(result?.dictionary?["answer"]?.double, 42.23)
    }
    
    func testDecodingAComplexObject() {
        let result = try? JSONDecoder().decode(MobilityboxJSONValue.self, from: "{\"complex\": [{\"a\": \"b\"}, {\"foo\": \"bar\",\"lol\": \"rofl\"}]}".data(using: .utf8)!)
        XCTAssertEqual(result?.dictionary?["complex"]?.array?[1].dictionary?["lol"]?.string, "rofl")
    }
    
    func testEncodingASimpleArray() {
        let jsonValue = MobilityboxJSONValue.array([MobilityboxJSONValue.string("Hallo Welt")])
        let result = try? String(data: JSONEncoder().encode(jsonValue), encoding: .utf8)
        XCTAssertEqual(result, "[\"Hallo Welt\"]")
    }
    
    func testEncodingASimpleObject() {
        let jsonValue = MobilityboxJSONValue.dictionary(["Hallo" : MobilityboxJSONValue.string("Welt")])
        let result = try? String(data: JSONEncoder().encode(jsonValue), encoding: .utf8)
        XCTAssertEqual(result, "{\"Hallo\":\"Welt\"}")
    }
    
    func testEncodingASimpleObjectWithInteger() {
        let jsonValue = MobilityboxJSONValue.dictionary(["answer" : MobilityboxJSONValue.double(42)])
        let result = try? String(data: JSONEncoder().encode(jsonValue), encoding: .utf8)
        XCTAssertEqual(result, "{\"answer\":42}")
    }
    
    func testEncodingASimpleObjectWithBooleanTrue() {
        let jsonValue = MobilityboxJSONValue.dictionary(["answer" : MobilityboxJSONValue.bool(true)])
        let result = try? String(data: JSONEncoder().encode(jsonValue), encoding: .utf8)
        XCTAssertEqual(result, "{\"answer\":true}")
    }
    
    func testEncodingASimpleObjectWithBooleanFalse() {
        let jsonValue = MobilityboxJSONValue.dictionary(["answer" : MobilityboxJSONValue.bool(false)])
        let result = try? String(data: JSONEncoder().encode(jsonValue), encoding: .utf8)
        XCTAssertEqual(result, "{\"answer\":false}")
    }
    
    func testEncodingASimpleObjectWithNil() {
        let jsonValue = MobilityboxJSONValue.dictionary(["answer" : MobilityboxJSONValue.nil])
        let result = try? String(data: JSONEncoder().encode(jsonValue), encoding: .utf8)
        XCTAssertEqual(result, "{\"answer\":null}")
    }
    
    func testEncodingASimpleObjectWithDouble() {
        let jsonValue = MobilityboxJSONValue.dictionary(["answer" : MobilityboxJSONValue.double(42.23)])
        let result = try? String(data: JSONEncoder().encode(jsonValue), encoding: .utf8)
        XCTAssertEqual(result, "{\"answer\":42.229999999999997}")
    }
    
    func testDecodingAndReencodingAComplexObject() {
        let decoded = try? JSONDecoder().decode(MobilityboxJSONValue.self, from: "{\"complex\": [{\"a\": \"b\"}, {\"foo\": \"bar\",\"lol\": \"rofl\"}]}".data(using: .utf8)!)
        let result = try? String(data: JSONEncoder().encode(decoded), encoding: .utf8)
        XCTAssertEqual(result, "{\"complex\":[{\"a\":\"b\"},{\"foo\":\"bar\",\"lol\":\"rofl\"}]}")
    }
}
