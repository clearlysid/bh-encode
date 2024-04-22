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
    var assetWriterInput: AVAssetWriterInput
    var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor

    init(_ width: Int, _ height: Int, _ outFile: URL) {
        self.width = width;
        self.height = height;

        // Setup AVAssetWriter
        // Create AVAssetWriter for a mp4 file
        self.assetWriter = try! AVAssetWriter(url: outFile, fileType: .mp4)
        
        // Prepare the AVAssetWriterInputPixelBufferAdaptor
        let outputSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height
        ]

        self.assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: outputSettings)
        self.assetWriterInput.expectsMediaDataInRealTime = true

        let sourcePixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
        ]

        self.pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: self.assetWriterInput,
            sourcePixelBufferAttributes: sourcePixelBufferAttributes
        )
        
        if self.assetWriter.canAdd(self.assetWriterInput) {
            self.assetWriter.add(self.assetWriterInput)
        }
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

// NOTES: make any timestamp adjustments in Rust before passing here

@_cdecl("encoder_ingest_yuv_frame")
func encoderIngestYuvFrame(
    _ enc: Encoder,
    _ width: Int,
    _ height: Int,
    _ displayTime: Int,
    _ luminanceStride: Int,
    _ luminanceBytesRaw: SRData,
    _ chrominanceStride: Int,
    _ chrominanceBytesRaw: SRData
) {
    print("Swift: yuvDisplayTime: \(displayTime)")

    var luminanceBytes = luminanceBytesRaw.toArray()
    var chrominanceBytes = chrominanceBytesRaw.toArray()

    // TODO: create a CVPixelBuffer from YUV data so we can prepare for encoding

    // Create a CVPixelBuffer from YUV data
    let pixelBufferAttributes: CFDictionary = [
        kCVPixelBufferIOSurfacePropertiesKey: [:] as CFDictionary,
        kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
    ] as CFDictionary

    var pixelBuffer: CVPixelBuffer?
    let status = CVPixelBufferCreate(
        kCFAllocatorDefault,
        width,
        height,
        kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
        pixelBufferAttributes,
        &pixelBuffer
    )

    if status != kCVReturnSuccess {
        print("Failed to create CVPixelBuffer")
        return
    }

    // Get the base addresses of the Y and UV planes
    CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
    let yPlaneAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer!, 0)
    let uvPlaneAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer!, 1)

    // Copy the luminance (Y) data to the Y plane
    let yDestPointer = yPlaneAddress?.assumingMemoryBound(to: UInt8.self)
    yDestPointer?.assign(from: luminanceBytes, count: luminanceBytes.count)

    // Copy the chrominance (UV) data to the UV plane
    let uvDestPointer = uvPlaneAddress?.assumingMemoryBound(to: UInt8.self)
    uvDestPointer?.assign(from: chrominanceBytes, count: chrominanceBytes.count)

    CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

    print("Swift: ingested frame")
    
}

@_cdecl("encoder_finish")
func encoderFinish(_ enc: Encoder) {
    print("Swift: finish encoding")
}
