import SwiftRs
import Foundation
import AVFoundation
import VideoToolbox
import CoreVideo
import CoreImage

// TODO: handle errors better

class Encoder: NSObject {
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


@_cdecl("encoder_init")
func encoderInit(_ width: Int, _ height: Int, _ outFile: SRString) -> Encoder {
    return Encoder(
        width,
        height,
        URL(fileURLWithPath: outFile.toString())
    )
}

@_cdecl("encoder_ingest_yuv_frame")
func encoderIngestYuvFrame(
    _ enc: Encoder,
    _ width: Int,
    _ height: Int,
    _ displayTime: Int,
    _ luminanceStride: Int,
    _ luminanceBytes: SRData,
    _ chrominanceStride: Int,
    _ chrominanceBytes: SRData
    ) {

    print("Swift: yuvDisplayTime: \(displayTime)")


    // print("Swift: displayTime: \(luminanceBytes.data)")

    // Make any timestamp adjustments here
    
    // Create a pixel buffer

    // Create AVAssetWriterInputPixelBufferAdaptor



    // print("AssetWriter: \(videoExporter.assetWriter.availableMediaTypes)")
}

@_cdecl("encoder_finish")
func encoderFinish(_ enc: Encoder) {
    print("Swift: finish encoding")
}
