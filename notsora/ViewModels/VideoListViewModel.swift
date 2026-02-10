import Foundation
import SwiftUI
import UniformTypeIdentifiers

@Observable
final class VideoListViewModel {
    var videos: [VideoFile] = []
    var selectedVideoID: UUID?
    var globalSettings = CompressionSettings()
    var perVideoSettings: [UUID: CompressionSettings] = [:]
    var perVideoMetadata: [UUID: MetadataFields] = [:]
    var perVideoOutputFilenames: [UUID: String] = [:]
    var outputDirectory: URL?
    var isProbing = false

    var selectedVideo: VideoFile? {
        guard let id = selectedVideoID else { return nil }
        return videos.first { $0.id == id }
    }

    func settingsFor(_ video: VideoFile) -> CompressionSettings {
        perVideoSettings[video.id] ?? globalSettings
    }

    func metadataFor(_ video: VideoFile) -> MetadataFields {
        perVideoMetadata[video.id] ?? MetadataFields()
    }

    func outputFilenameFor(_ video: VideoFile) -> String {
        if let custom = perVideoOutputFilenames[video.id], !custom.isEmpty {
            return custom
        }
        let settings = settingsFor(video)
        let name = video.url.deletingPathExtension().lastPathComponent
        return "\(name)_compressed.\(settings.container.fileExtension)"
    }

    func updateSettings(_ settings: CompressionSettings, for video: VideoFile) {
        perVideoSettings[video.id] = settings
    }

    func updateMetadata(_ metadata: MetadataFields, for video: VideoFile) {
        perVideoMetadata[video.id] = metadata
    }

    func updateOutputFilename(_ filename: String, for video: VideoFile) {
        perVideoOutputFilenames[video.id] = filename
    }

    func addFiles(urls: [URL]) async {
        isProbing = true
        defer { isProbing = false }

        for url in urls {
            let ext = url.pathExtension.lowercased()
            guard AppConstants.supportedExtensions.contains(ext) else { continue }
            guard !videos.contains(where: { $0.url == url }) else { continue }

            let fileSize: Int64
            if let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
               let size = attrs[.size] as? Int64 {
                fileSize = size
            } else {
                fileSize = 0
            }

            var video = VideoFile(
                url: url,
                filename: url.lastPathComponent,
                fileSize: fileSize
            )

            do {
                let probe = try await VideoProber.probe(url: url)
                video.duration = probe.duration
                video.width = probe.width
                video.height = probe.height
                video.videoCodec = probe.videoCodec
                video.audioCodec = probe.audioCodec
                video.framerate = probe.framerate
            } catch {
                // Still add the file, just without metadata
                print("Probe failed for \(url.lastPathComponent): \(error)")
            }

            videos.append(video)

            if selectedVideoID == nil {
                selectedVideoID = video.id
            }
        }
    }

    func removeVideos(ids: Set<UUID>) {
        videos.removeAll { ids.contains($0.id) }
        for id in ids {
            perVideoSettings.removeValue(forKey: id)
            perVideoMetadata.removeValue(forKey: id)
            perVideoOutputFilenames.removeValue(forKey: id)
        }
        if let selected = selectedVideoID, ids.contains(selected) {
            selectedVideoID = videos.first?.id
        }
    }

    func removeVideo(_ video: VideoFile) {
        removeVideos(ids: [video.id])
    }

    func showOpenPanel() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = AppConstants.supportedExtensions.compactMap {
            UTType(filenameExtension: $0)
        }

        if panel.runModal() == .OK {
            Task {
                await addFiles(urls: panel.urls)
            }
        }
    }

    func showOutputDirectoryPicker() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.prompt = "Select Output Folder"

        if panel.runModal() == .OK {
            outputDirectory = panel.url
        }
    }
}
