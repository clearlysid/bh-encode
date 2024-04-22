use anyhow::Error;
use scap::frame::Frame;

#[cfg(target_os = "macos")]
use swift_rs::{swift, Int, SRData, SRString};

#[cfg(target_os = "macos")]
swift!(fn encoder_init(
    width: Int,
    height: Int,
    out_file: SRString
) -> *mut std::ffi::c_void);

#[cfg(target_os = "macos")]
swift!(fn encoder_ingest_yuv_frame(
    enc: *mut std::ffi::c_void,
    width: Int,
    height: Int,
    display_time: Int,
    luminance_stride: Int,
    luminance_bytes: SRData,
    chrominance_stride: Int,
    chrominance_bytes: SRData
));

#[cfg(target_os = "macos")]
swift!(fn encoder_ingest_bgra_frame(
    enc: *mut std::ffi::c_void,
    width: Int,
    height: Int,
    display_time: Int,
    bytes_per_row: Int,
    bgra_bytes_raw: SRData
));

#[cfg(target_os = "macos")]
swift!(fn encoder_finish(enc: *mut std::ffi::c_void));

pub struct VideoEncoder {
    first_timespan: u64,

    #[cfg(target_os = "macos")]
    encoder: *mut std::ffi::c_void,
}

#[derive(Debug)]
pub struct VideoEncoderOptions {
    pub width: u32,
    pub height: u32,
    pub path: String,
}

impl VideoEncoder {
    pub fn new(options: VideoEncoderOptions) -> Result<Self, Error> {
        let encoder = unsafe {
            encoder_init(
                options.width as Int,
                options.height as Int,
                options.path.as_str().into(),
            )
        };

        Ok(Self {
            first_timespan: 0,
            encoder,
        })
    }

    pub fn ingest_next_frame(&mut self, frame: &Frame) -> Result<(), Error> {
        match frame {
            Frame::YUVFrame(data) => {
                if self.first_timespan == 0 {
                    self.first_timespan = data.display_time;
                }

                let timestamp = data.display_time - self.first_timespan;

                #[cfg(target_os = "macos")]
                unsafe {
                    encoder_ingest_yuv_frame(
                        self.encoder,
                        data.width as Int,
                        data.height as Int,
                        timestamp as Int,
                        data.luminance_stride as Int,
                        data.luminance_bytes.as_slice().into(),
                        data.chrominance_stride as Int,
                        data.chrominance_bytes.as_slice().into(),
                    );
                }
            }
            Frame::BGRA(data) => {
                if self.first_timespan == 0 {
                    self.first_timespan = data.display_time;
                }

                let timestamp = data.display_time - self.first_timespan;

                #[cfg(target_os = "macos")]
                unsafe {
                    encoder_ingest_bgra_frame(
                        self.encoder,
                        data.width as Int,
                        data.height as Int,
                        timestamp as Int,
                        data.width as Int,
                        data.data.as_slice().into(),
                    );
                }
            }
            _ => {
                println!("unsupported frame type atm");
            }
        }

        Ok(())
    }

    pub fn finish(&mut self) -> Result<(), Error> {
        #[cfg(target_os = "macos")]
        unsafe {
            encoder_finish(self.encoder);
        }

        Ok(())
    }
}
