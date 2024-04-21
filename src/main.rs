// This program is just a testbed for the library itself
// Refer to the lib.rs file for the actual implementation

use bh_encode::encoder;
use scap::{capturer::{Capturer, CGRect, CGPoint, CGSize, self}, frame::Frame};

fn main() {
    // #1 Check if the platform is supported
    let supported = scap::is_supported();
    if !supported {
        println!("❌ Platform not supported");
        return;
    } else {
        println!("✅ Platform supported");
    }

    // #2 Check if we have permission to capture the screen
    let has_permission = scap::has_permission();
    if !has_permission {
        println!("❌ Permission not granted");
        return;
    } else {
        println!("✅ Permission granted");
    }

    // #3 Get recording targets (WIP)
    let targets = scap::get_targets();
    println!("🎯 Targets: {:?}", targets);

    const FRAME_TYPE:scap::frame::FrameType = scap::frame::FrameType::BGRAFrame;
    // #4 Create Options
    let options = capturer::Options {
        fps: 60,
        targets,
        show_cursor: true,
        show_highlight: true,
        excluded_targets: None,
        output_type: FRAME_TYPE,
        output_resolution: scap::capturer::Resolution::_720p,
        source_rect: Some(CGRect {
            origin: CGPoint { x: 0.0, y: 0.0 },
            size: CGSize { width: 1200.0, height: 400.0 }
        }),
        ..Default::default()
    };

    // #5 Create Recorder
    let mut recorder = Capturer::new(options);
    let [output_width, output_height] = recorder.get_output_frame_size();

    // Create Encoder
    let mut encoder = encoder::Encoder::new(encoder::Options {
        output: encoder::Output::FileOutput(encoder::FileOutput {
            output_filename: "1.mp4".to_owned(),
        }),
        input: encoder::InputOptions {
            width: output_width as usize,
            height: output_height as usize,
            frame_type: FRAME_TYPE,
            base_timestamp: None
        },
    });

    // #6 Start Capture
    recorder.start_capture();

    // #7 Capture 100 frames
    for _ in 0..100 {
        let frame = recorder.get_next_frame().expect("Error");
        match &frame {
            Frame::YUVFrame(frame) => {
                println!("Frame width: {}, Frame height: {}", frame.width, frame.height);
            }
            Frame::BGR0(_) => {
                println!("Recvd windows frame");
            }
            Frame::RGB(frame) => {
                println!("Recieved frame of width {} and height {}", frame.width, frame.height);
            }
            _ => {
                println!("Received frame of unknown type");
            }
        }


        encoder.ingest_next_video_frame(&frame);
    }

    // #8 Stop Capture
    recorder.stop_capture();

    // Stop Encoder
    encoder.done();
}