use pyo3::prelude::*;
use statistics as stat;

#[pyfunction]
fn mean(values: Vec<f64>) -> f64 {
    stat::mean(&values)
}

#[pyfunction]
fn stddev(values: Vec<f64>) -> f64 {
    stat::stddev(&values)
}

#[pyclass]
struct Array(Vec<f64>);

#[pymethods]
impl Array {
    #[new]
    fn new(values: Vec<f64>) -> Self {
        Self(values)
    }

    fn mean(&self) -> f64 {
        stat::mean(&self.0)
    }

    fn stddev(&self) -> f64 {
        stat::stddev(&self.0)
    }
}

#[pymodule]
fn bind_pyo3(m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(mean, m)?)?;
    m.add_function(wrap_pyfunction!(stddev, m)?)?;
    m.add_class::<Array>()
}
