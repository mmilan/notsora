import SwiftUI

struct MetadataEditorView: View {
    @Binding var metadata: MetadataFields

    var body: some View {
        DisclosureGroup("Metadata") {
            VStack(alignment: .leading, spacing: 12) {
                metadataField("Title", text: $metadata.title)
                metadataField("Artist", text: $metadata.artist)
                metadataField("Album", text: $metadata.album)
                metadataField("Genre", text: $metadata.genre)
                metadataField("Date", text: $metadata.date)
                metadataField("Copyright", text: $metadata.copyright)
                metadataField("Comment", text: $metadata.comment)
                metadataField("Description", text: $metadata.description)

                Divider()

                // Custom tags
                HStack {
                    Text("Custom Tags")
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Button {
                        metadata.customTags.append(CustomTag())
                    } label: {
                        Label("Add Tag", systemImage: "plus.circle")
                            .foregroundStyle(Theme.twitterBlue)
                    }
                    .buttonStyle(.borderless)
                }

                ForEach($metadata.customTags) { $tag in
                    HStack(spacing: 8) {
                        TextField("Key", text: $tag.key)
                            .frame(width: 120)
                        TextField("Value", text: $tag.value)
                        Button {
                            metadata.customTags.removeAll { $0.id == tag.id }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(Theme.error)
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            .padding(.top, 4)
        }
        .tint(Theme.twitterBlue)
    }

    @ViewBuilder
    private func metadataField(_ label: String, text: Binding<String>) -> some View {
        LabeledContent(label) {
            TextField(label, text: text)
                .textFieldStyle(.roundedBorder)
        }
    }
}
