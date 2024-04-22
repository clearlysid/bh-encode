use anyhow::Error;
use scap::frame::Frame;

#[cfg(target_os = "macos")]
mod mac;

pub struct VideoEncoder {
    first_timespan: Option<u64>,
}

pub struct VideoEncoderOptions {
    pub width: u32,
    pub height: u32,
    pub path: String,
}

impl VideoEncoder {
    pub fn new(options: VideoEncoderOptions) -> Result<Self, Error> {
        println!("encoder created!");

        mac::log();

        Ok(Self {
            first_timespan: None,
        })
    }

    pub fn ingest_next_video_frame(&mut self, frame: &Frame) -> Result<(), Error> {
        println!("ingesting frame!");
        Ok(())
    }

    pub fn finish(&mut self) -> Result<(), Error> {
        println!("encoder finished!");
        Ok(())
    }
}
