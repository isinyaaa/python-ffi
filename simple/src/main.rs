use rand::prelude::*;
use std::time::Instant;

const N: u64 = 100_000_000;

pub fn main() {
    let mut rng = rand::rng();
    let vs: Vec<u64> = (0..N)
        .map(|_| rng.random_range(0..=92_233_720_368))
        .collect();
    let start = Instant::now();
    let v: u64 = vs.iter().sum();
    let duration = start.elapsed();
    println!("rust {} {}us", v, duration.as_micros())
}
