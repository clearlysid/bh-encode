import SwiftRs
import Foundation
import AVFoundation
import VideoToolbox

class VideoExporter: NSObject {
    var width: Int
    var height: Int
    var frameRate: Int
    var outputFilePath: String

    init(_ width: Int, _ height: Int, _ outputFilePath: String) {
        self.width = width;
        self.height = height;
        self.frameRate = 30;
        self.outputFilePath = outputFilePath;
    }
}


@_cdecl("exporter_init")
func exporterInit() -> VideoExporter {
    print("Swift: init VideoExporter")
    return VideoExporter(1920, 1080, "output.mp4")
}

@_cdecl("exporter_ingest_frame")
func exporterIngestFrame(_ videoExporter: VideoExporter) {
    print("Swift: ingest frame")
    // print("Width: \(videoExporter.width)")
}

@_cdecl("exporter_finish")
func exporterFinish(_ videoExporter: VideoExporter) {
    print("Swift: finish encoding")
}
