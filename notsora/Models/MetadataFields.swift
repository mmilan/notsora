import Foundation

struct MetadataFields: Codable, Equatable {
    var title: String = ""
    var artist: String = ""
    var album: String = ""
    var genre: String = ""
    var date: String = ""
    var copyright: String = ""
    var comment: String = ""
    var description: String = ""
    var customTags: [CustomTag] = []

    var isEmpty: Bool {
        title.isEmpty && artist.isEmpty && album.isEmpty && genre.isEmpty &&
        date.isEmpty && copyright.isEmpty && comment.isEmpty && description.isEmpty &&
        customTags.isEmpty
    }

    /// Returns ffmpeg metadata arguments: ["-metadata", "key=value", ...]
    var ffmpegArguments: [String] {
        var args: [String] = []

        let fields: [(String, String)] = [
            ("title", title),
            ("artist", artist),
            ("album", album),
            ("genre", genre),
            ("date", date),
            ("copyright", copyright),
            ("comment", comment),
            ("description", description),
        ]

        for (key, value) in fields where !value.isEmpty {
            args.append("-metadata")
            args.append("\(key)=\(value)")
        }

        for tag in customTags where !tag.key.isEmpty && !tag.value.isEmpty {
            args.append("-metadata")
            args.append("\(tag.key)=\(tag.value)")
        }

        return args
    }
}

struct CustomTag: Identifiable, Codable, Hashable, Equatable {
    let id: UUID
    var key: String
    var value: String

    init(id: UUID = UUID(), key: String = "", value: String = "") {
        self.id = id
        self.key = key
        self.value = value
    }
}
