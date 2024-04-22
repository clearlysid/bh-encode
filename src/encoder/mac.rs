use swift_rs::swift;

swift!(fn log_hello());

pub fn log() {
    unsafe { log_hello() }
}
