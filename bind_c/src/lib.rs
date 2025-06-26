use statistics as stat;

fn pointer_to_vec<T: Clone>(values: *const T, n: u64) -> Vec<T> {
    unsafe { std::slice::from_raw_parts(values, n as usize) }.into()
}

#[unsafe(no_mangle)]
pub extern "C" fn mean(values: *const f64, n: u64) -> f64 {
    stat::mean(&pointer_to_vec(values, n))
}

#[unsafe(no_mangle)]
pub extern "C" fn stddev(values: *const f64, n: u64) -> f64 {
    stat::stddev(&pointer_to_vec(values, n))
}

pub struct Array(Vec<f64>);

#[unsafe(no_mangle)]
pub extern "C" fn array_init(values: *const f64, n: u64) -> *const Array {
    let boxed = Box::new(Array(pointer_to_vec(values, n)));
    Box::into_raw(boxed)
}

#[unsafe(no_mangle)]
pub extern "C" fn array_mean(arr: *const Array) -> f64 {
    stat::mean(&unsafe { &*arr }.0)
}

#[unsafe(no_mangle)]
pub extern "C" fn array_stddev(arr: *const Array) -> f64 {
    stat::stddev(&unsafe { &*arr }.0)
}
