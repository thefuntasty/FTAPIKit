
struct AnyEncodable: Encodable {
    private let anyEncode: (Encoder) throws -> Void

    init(_ encodable: Encodable) {
        anyEncode = { encoder in
            try encodable.encode(to: encoder)
        }
    }

    func encode(to encoder: Encoder) throws {
        try anyEncode(encoder)
    }
}
