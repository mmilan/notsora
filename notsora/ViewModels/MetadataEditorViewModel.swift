import Foundation

@Observable
final class MetadataEditorViewModel {
    var metadata: MetadataFields

    init(metadata: MetadataFields = MetadataFields()) {
        self.metadata = metadata
    }

    func addCustomTag() {
        metadata.customTags.append(CustomTag())
    }

    func removeCustomTag(at offsets: IndexSet) {
        metadata.customTags.remove(atOffsets: offsets)
    }

    func removeCustomTag(id: UUID) {
        metadata.customTags.removeAll { $0.id == id }
    }

    func clearAll() {
        metadata = MetadataFields()
    }
}
