import Foundation

struct MultipartFormData {

    private let parts: [MultipartBodyPart]
    private let boundary: String
    private let temporaryUrl: URL = makeTemporaryUrl()

    init(parts: [MultipartBodyPart], boundary: String = "FTAPIKit-" + UUID().uuidString) {
        self.parts = parts
        self.boundary = boundary
    }

    var contentLength: Int64? {
        (try? FileManager.default.attributesOfItem(atPath: temporaryUrl.path)[.size] as? Int64)?.flatMap { $0 }
    }

    var contentType: String {
        "multipart/form-data; charset=utf-8; boundary=\(boundary)"
    }

    private static func makeTemporaryUrl() -> URL {
        let urls = FileManager.default.urls(for: .itemReplacementDirectory, in: .userDomainMask)
        let directory = urls.first ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)

        return directory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("body")
    }

    func inputStream() throws -> InputStream {
        try outputStream()
        guard let inputStream = InputStream(url: temporaryUrl) else {
            throw URLError(.cannotOpenFile, userInfo: ["url": temporaryUrl])
        }
        return inputStream
    }

    private func outputStream() throws {
        guard let outputStream = OutputStream(url: temporaryUrl, append: false) else {
            throw URLError(.cannotOpenFile, userInfo: ["url": temporaryUrl])
        }
        outputStream.open()
        defer {
            outputStream.close()
        }
        let boundaryData = Data("--\(boundary)".utf8)
        for part in parts {
            try outputStream.write(data: boundaryData)
            try outputStream.writeLine()
            try write(headers: part.headers, to: outputStream)
            try outputStream.writeLine()
            try outputStream.write(inputStream: part.inputStream)
            try outputStream.writeLine()
        }
        try outputStream.write(data: boundaryData)
        try outputStream.writeLine(string: "--")
    }

    private func write(headers: [String: String], to outputStream: OutputStream) throws {
        for (key, value) in headers {
            try outputStream.writeLine(string: "\(key): \(value)")
        }
    }
}
