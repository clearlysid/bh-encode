use anyhow::Error;
use scap::frame::Frame;

use swift_rs::swift;

#[cfg(target_os = "macos")]
swift!(fn exporter_init() -> *mut std::ffi::c_void);

#[cfg(target_os = "macos")]
swift!(fn exporter_ingest_frame(exporter: *mut std::ffi::c_void));

#[cfg(target_os = "macos")]
swift!(fn exporter_finish(exporter: *mut std::ffi::c_void));

pub struct VideoEncoder {
    first_timespan: Option<u64>,

    #[cfg(target_os = "macos")]
    exporter: *mut std::ffi::c_void,
}

pub struct VideoEncoderOptions {
    pub width: u32,
    pub height: u32,
    pub path: String,
}

impl VideoEncoder {
    pub fn new(options: VideoEncoderOptions) -> Result<Self, Error> {
        println!("encoder created!");

        let exporter = unsafe { exporter_init() };

        Ok(Self {
            first_timespan: None,
            exporter,
        })
    }

    pub fn ingest_next_video_frame(&mut self, frame: &Frame) -> Result<(), Error> {
        // println!("ingesting frame!");

        #[cfg(target_os = "macos")]
        unsafe {
            exporter_ingest_frame(self.exporter);
        }

        Ok(())
    }

    pub fn finish(&mut self) -> Result<(), Error> {
        println!("encoder finished!");

        #[cfg(target_os = "macos")]
        unsafe {
            exporter_finish(self.exporter);
        }

        Ok(())
    }
}
