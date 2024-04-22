import SwiftRs
import Foundation
import AVFoundation
import VideoToolbox
import CoreVideo
import CoreImage

// TODO: handle errors better

class VideoExporter: NSObject {
    var width: Int
    var height: Int
    var assetWriter: AVAssetWriter

    init(_ width: Int, _ height: Int, _ outFile: URL) {
        self.width = width;
        self.height = height;

        // Setup AVAssetWriter

        // Create AVAssetWriter for a mp4 file
        self.assetWriter = try! AVAssetWriter(url: outFile, fileType: .mp4)
    }  
}


@_cdecl("exporter_init")
func exporterInit(_ width: Int, _ height: Int, _ outFile: SRString) -> VideoExporter {
    // SRString -> Swift String -> URL
    let url = URL(fileURLWithPath: outFile.toString())
    return VideoExporter(width, height, url)
}

@_cdecl("exporter_ingest_yuv_frame")
func exporterIngesYuvFrame(
    _ videoExporter: VideoExporter,
    _ width: Int,
    _ height: Int,
    _ displayTime: Int,
    _ luminanceStride: Int,
    _ luminanceBytes: SRData,
    _ chrominanceStride: Int,
    _ chrominanceBytes: SRData
    ) {
    print("Swift: displayTime: \(luminanceStride)")
    // print("AssetWriter: \(videoExporter.assetWriter.availableMediaTypes)")
}

@_cdecl("exporter_finish")
func exporterFinish(_ videoExporter: VideoExporter) {
    print("Swift: finish encoding")
}
