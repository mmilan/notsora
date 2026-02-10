import Foundation

enum FFmpegProgressParser {
    private static let timeRegex = try! NSRegularExpression(
        pattern: #"time=(\d+):(\d+):(\d+\.\d+)"#
    )

    /// Parses a line of ffmpeg stderr output and returns the current time in seconds, or nil if not found.
    static func parseTime(from line: String) -> Double? {
        let range = NSRange(line.startIndex..., in: line)
        guard let match = timeRegex.firstMatch(in: line, range: range) else {
            return nil
        }

        guard match.numberOfRanges >= 4,
              let hoursRange = Range(match.range(at: 1), in: line),
              let minutesRange = Range(match.range(at: 2), in: line),
              let secondsRange = Range(match.range(at: 3), in: line) else {
            return nil
        }

        let hours = Double(line[hoursRange]) ?? 0
        let minutes = Double(line[minutesRange]) ?? 0
        let seconds = Double(line[secondsRange]) ?? 0

        return hours * 3600 + minutes * 60 + seconds
    }

    /// Calculates progress fraction (0.0 to 1.0) given current time and total duration.
    static func progressFraction(currentTime: Double, totalDuration: Double) -> Double {
        guard totalDuration > 0 else { return 0 }
        return min(max(currentTime / totalDuration, 0), 1.0)
    }

    /// Estimates remaining time based on elapsed time and progress.
    static func estimateTimeRemaining(elapsed: TimeInterval, progress: Double) -> Double? {
        guard progress > 0.01 else { return nil }
        let totalEstimated = elapsed / progress
        return max(totalEstimated - elapsed, 0)
    }
}
