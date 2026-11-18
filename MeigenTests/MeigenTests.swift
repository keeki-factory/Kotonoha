//
//  MeigenTests.swift
//  MeigenTests
//  
//  Created by keeki-fami on 2026/11/13
//  
//

import Foundation
import Testing
@testable import Meigen

struct MeigenTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        // Swift Testing Documentation
        // https://developer.apple.com/documentation/testing
    }

    @Test func quoteCardTypeIsEncodedAndDecoded() throws {
        let quote = Quote(text: "言葉", cardType: .text)
        let data = try JSONEncoder().encode(quote)
        let decoded = try JSONDecoder().decode(Quote.self, from: data)

        #expect(decoded.cardType == .text)
    }

    @Test func quoteWithoutCardTypeDefaultsToImage() throws {
        let json = """
        {
            "id": "\(UUID().uuidString)",
            "text": "言葉",
            "createdAt": 0,
            "updatedAt": 0
        }
        """
        let decoded = try JSONDecoder().decode(Quote.self, from: Data(json.utf8))

        #expect(decoded.cardType == .image)
    }

    @Test func quoteRecordPreservesCardType() {
        let quote = Quote(text: "言葉", cardType: .text)
        let record = QuoteRecord(quote: quote)

        #expect(record.asDomain().cardType == .text)
    }

}
