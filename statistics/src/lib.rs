pub fn mean(values: &[f64]) -> f64 {
    values.into_iter().sum::<f64>() / (values.len() as f64)
}

pub fn stddev(values: &[f64]) -> f64 {
    let mean = mean(&values);
    let mut squared_sum = 0.0;
    for v in values {
        let shifted = v - mean;
        squared_sum += shifted * shifted;
    }
    (squared_sum / (values.len() as f64)).sqrt()
}
