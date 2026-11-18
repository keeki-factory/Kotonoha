import Foundation

enum CardType: String, Codable, Hashable, Sendable {
    case text
    case image
}

/// Portable domain entity. Keep this type independent of SwiftUI and SwiftData.
struct Quote: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var text: String
    var source: String?
    var author: String?
    var detail: String?
    var cardType: CardType
    /// Relative filename in the app's documents/Quotes directory, never an absolute path.
    var imageFilename: String?
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        text: String,
        source: String? = nil,
        author: String? = nil,
        detail: String? = nil,
        cardType: CardType = .image,
        imageFilename: String? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.text = text
        self.source = Self.cleaned(source)
        self.author = Self.cleaned(author)
        self.detail = Self.cleaned(detail)
        self.cardType = cardType
        self.imageFilename = imageFilename
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    private enum CodingKeys: String, CodingKey {
        case id, text, source, author, detail, cardType, imageFilename, createdAt, updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        source = try container.decodeIfPresent(String.self, forKey: .source)
        author = try container.decodeIfPresent(String.self, forKey: .author)
        detail = try container.decodeIfPresent(String.self, forKey: .detail)
        cardType = try container.decodeIfPresent(CardType.self, forKey: .cardType) ?? .image
        imageFilename = try container.decodeIfPresent(String.self, forKey: .imageFilename)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }

    // カードに表示するtextを返すcomputing property
    var shareText: String {
        var lines = ["「\(text)」"]
        if let author { lines.append("— \(author)") }
        if let source { lines.append("出典：\(source)") }
        return lines.joined(separator: "\n")
    }

    static func cleaned(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    static func validate(text: String) -> String? {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "名言を入力してください。"
            : nil
    }
}
