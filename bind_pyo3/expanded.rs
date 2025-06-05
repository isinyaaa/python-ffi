#![feature(prelude_import)]
#[prelude_import]
use std::prelude::rust_2024::*;
#[macro_use]
extern crate std;
use pyo3::prelude::*;
use statistics as stat;

fn mean(values: Vec<f64>) -> f64 { stat::mean(&values) }
#[doc(hidden)]
mod mean {
    pub(crate) struct MakeDef;
    pub const _PYO3_DEF: ::pyo3::impl_::pymethods::PyMethodDef =
        MakeDef::_PYO3_DEF;
}
#[allow(unknown_lints, non_local_definitions)]
impl mean::MakeDef {
    const _PYO3_DEF: ::pyo3::impl_::pymethods::PyMethodDef =
        ::pyo3::impl_::pymethods::PyMethodDef::fastcall_cfunction_with_keywords(c"mean",
            {
                unsafe extern "C" fn trampoline(_slf:
                        *mut ::pyo3::ffi::PyObject,
                    _args: *const *mut ::pyo3::ffi::PyObject,
                    _nargs: ::pyo3::ffi::Py_ssize_t,
                    _kwnames: *mut ::pyo3::ffi::PyObject)
                    -> *mut ::pyo3::ffi::PyObject {
                    ::pyo3::impl_::trampoline::fastcall_with_keywords(_slf,
                        _args, _nargs, _kwnames, __pyfunction_mean)
                }
                trampoline
            }, c"mean(values)\n--\n\n");
}
#[allow(non_snake_case)]
unsafe fn __pyfunction_mean<'py>(py: ::pyo3::Python<'py>,
    _slf: *mut ::pyo3::ffi::PyObject,
    _args: *const *mut ::pyo3::ffi::PyObject, _nargs: ::pyo3::ffi::Py_ssize_t,
    _kwnames: *mut ::pyo3::ffi::PyObject)
    -> ::pyo3::PyResult<*mut ::pyo3::ffi::PyObject> {
    let function = mean;
    const DESCRIPTION: ::pyo3::impl_::extract_argument::FunctionDescription =
        ::pyo3::impl_::extract_argument::FunctionDescription {
            cls_name: ::std::option::Option::None,
            func_name: "mean",
            positional_parameter_names: &["values"],
            positional_only_parameters: 0usize,
            required_positional_parameters: 1usize,
            keyword_only_parameters: &[],
        };
    let mut output = [::std::option::Option::None; 1usize];
    let (_args, _kwargs) =
        DESCRIPTION.extract_arguments_fastcall::<::pyo3::impl_::extract_argument::NoVarargs,
                ::pyo3::impl_::extract_argument::NoVarkeywords>(py, _args,
                _nargs, _kwnames, &mut output)?;
    #[allow(clippy :: let_unit_value)]
    let mut holder_0 =
        ::pyo3::impl_::extract_argument::FunctionArgumentHolder::INIT;
    let result =
        {
            let ret =
                function({
                        #[allow(unused_imports)]
                        use ::pyo3::impl_::pyclass::Probe as _;
                        ::pyo3::impl_::extract_argument::extract_argument::<_,
                                    {
                                        ::pyo3::impl_::pyclass::IsOption::<Vec<f64>>::VALUE
                                    }>(unsafe {
                                    ::pyo3::impl_::extract_argument::unwrap_required_argument(output[0usize].as_deref())
                                }, &mut holder_0, "values")?
                    });
            {
                let result =
                    {
                        let obj = ret;

                        #[allow(clippy :: useless_conversion)]
                        ::pyo3::impl_::wrap::converter(&obj).wrap(obj).map_err(::core::convert::Into::<::pyo3::PyErr>::into)
                    };
                ::pyo3::impl_::wrap::converter(&result).map_into_ptr(py,
                    result)
            }
        };
    result
}

fn stddev(values: Vec<f64>) -> f64 { stat::stddev(&values) }
#[doc(hidden)]
mod stddev {
    pub(crate) struct MakeDef;
    pub const _PYO3_DEF: ::pyo3::impl_::pymethods::PyMethodDef =
        MakeDef::_PYO3_DEF;
}
#[allow(unknown_lints, non_local_definitions)]
impl stddev::MakeDef {
    const _PYO3_DEF: ::pyo3::impl_::pymethods::PyMethodDef =
        ::pyo3::impl_::pymethods::PyMethodDef::fastcall_cfunction_with_keywords(c"stddev",
            {
                unsafe extern "C" fn trampoline(_slf:
                        *mut ::pyo3::ffi::PyObject,
                    _args: *const *mut ::pyo3::ffi::PyObject,
                    _nargs: ::pyo3::ffi::Py_ssize_t,
                    _kwnames: *mut ::pyo3::ffi::PyObject)
                    -> *mut ::pyo3::ffi::PyObject {
                    ::pyo3::impl_::trampoline::fastcall_with_keywords(_slf,
                        _args, _nargs, _kwnames, __pyfunction_stddev)
                }
                trampoline
            }, c"stddev(values)\n--\n\n");
}
#[allow(non_snake_case)]
unsafe fn __pyfunction_stddev<'py>(py: ::pyo3::Python<'py>,
    _slf: *mut ::pyo3::ffi::PyObject,
    _args: *const *mut ::pyo3::ffi::PyObject, _nargs: ::pyo3::ffi::Py_ssize_t,
    _kwnames: *mut ::pyo3::ffi::PyObject)
    -> ::pyo3::PyResult<*mut ::pyo3::ffi::PyObject> {
    let function = stddev;
    const DESCRIPTION: ::pyo3::impl_::extract_argument::FunctionDescription =
        ::pyo3::impl_::extract_argument::FunctionDescription {
            cls_name: ::std::option::Option::None,
            func_name: "stddev",
            positional_parameter_names: &["values"],
            positional_only_parameters: 0usize,
            required_positional_parameters: 1usize,
            keyword_only_parameters: &[],
        };
    let mut output = [::std::option::Option::None; 1usize];
    let (_args, _kwargs) =
        DESCRIPTION.extract_arguments_fastcall::<::pyo3::impl_::extract_argument::NoVarargs,
                ::pyo3::impl_::extract_argument::NoVarkeywords>(py, _args,
                _nargs, _kwnames, &mut output)?;
    #[allow(clippy :: let_unit_value)]
    let mut holder_0 =
        ::pyo3::impl_::extract_argument::FunctionArgumentHolder::INIT;
    let result =
        {
            let ret =
                function({
                        #[allow(unused_imports)]
                        use ::pyo3::impl_::pyclass::Probe as _;
                        ::pyo3::impl_::extract_argument::extract_argument::<_,
                                    {
                                        ::pyo3::impl_::pyclass::IsOption::<Vec<f64>>::VALUE
                                    }>(unsafe {
                                    ::pyo3::impl_::extract_argument::unwrap_required_argument(output[0usize].as_deref())
                                }, &mut holder_0, "values")?
                    });
            {
                let result =
                    {
                        let obj = ret;

                        #[allow(clippy :: useless_conversion)]
                        ::pyo3::impl_::wrap::converter(&obj).wrap(obj).map_err(::core::convert::Into::<::pyo3::PyErr>::into)
                    };
                ::pyo3::impl_::wrap::converter(&result).map_into_ptr(py,
                    result)
            }
        };
    result
}

struct Array(Vec<f64>);
impl ::pyo3::types::DerefToPyAny for Array {}
unsafe impl ::pyo3::type_object::PyTypeInfo for Array {
    const NAME: &'static str = "Array";
    const MODULE: ::std::option::Option<&'static str> =
        ::core::option::Option::None;
    #[inline]
    fn type_object_raw(py: ::pyo3::Python<'_>)
        -> *mut ::pyo3::ffi::PyTypeObject {
        use ::pyo3::prelude::PyTypeMethods;
        <Array as
                        ::pyo3::impl_::pyclass::PyClassImpl>::lazy_type_object().get_or_init(py).as_type_ptr()
    }
}
impl ::pyo3::PyClass for Array {
    type Frozen = ::pyo3::pyclass::boolean_struct::False;
}
impl<'a, 'py>
    ::pyo3::impl_::extract_argument::PyFunctionArgument<'a, 'py, false> for
    &'a Array {
    type Holder = ::std::option::Option<::pyo3::PyRef<'py, Array>>;
    #[inline]
    fn extract(obj: &'a ::pyo3::Bound<'py, ::pyo3::PyAny>,
        holder: &'a mut Self::Holder) -> ::pyo3::PyResult<Self> {
        ::pyo3::impl_::extract_argument::extract_pyclass_ref(obj, holder)
    }
}
impl<'a, 'py>
    ::pyo3::impl_::extract_argument::PyFunctionArgument<'a, 'py, false> for
    &'a mut Array {
    type Holder = ::std::option::Option<::pyo3::PyRefMut<'py, Array>>;
    #[inline]
    fn extract(obj: &'a ::pyo3::Bound<'py, ::pyo3::PyAny>,
        holder: &'a mut Self::Holder) -> ::pyo3::PyResult<Self> {
        ::pyo3::impl_::extract_argument::extract_pyclass_ref_mut(obj, holder)
    }
}
impl<'py> ::pyo3::conversion::IntoPyObject<'py> for Array {
    type Target = Self;
    type Output =
        ::pyo3::Bound<'py,
        <Self as ::pyo3::conversion::IntoPyObject<'py>>::Target>;
    type Error = ::pyo3::PyErr;
    fn into_pyobject(self, py: ::pyo3::Python<'py>)
        ->
            ::std::result::Result<<Self as
            ::pyo3::conversion::IntoPyObject>::Output,
            <Self as ::pyo3::conversion::IntoPyObject>::Error> {
        ::pyo3::Bound::new(py, self)
    }
}
const _: () = { ::pyo3::impl_::pyclass::assert_pyclass_sync::<Array>(); };
impl ::pyo3::impl_::pyclass::PyClassImpl for Array {
    const IS_BASETYPE: bool = false;
    const IS_SUBCLASS: bool = false;
    const IS_MAPPING: bool = false;
    const IS_SEQUENCE: bool = false;
    const IS_IMMUTABLE_TYPE: bool = false;
    type BaseType = ::pyo3::PyAny;
    type ThreadChecker = ::pyo3::impl_::pyclass::SendablePyClass<Array>;
    type PyClassMutability =
        <<::pyo3::PyAny as
        ::pyo3::impl_::pyclass::PyClassBaseType>::PyClassMutability as
        ::pyo3::impl_::pycell::PyClassMutability>::MutableChild;
    type Dict = ::pyo3::impl_::pyclass::PyClassDummySlot;
    type WeakRef = ::pyo3::impl_::pyclass::PyClassDummySlot;
    type BaseNativeType = ::pyo3::PyAny;
    fn items_iter() -> ::pyo3::impl_::pyclass::PyClassItemsIter {
        use ::pyo3::impl_::pyclass::*;
        let collector = PyClassImplCollector::<Self>::new();
        static INTRINSIC_ITEMS: PyClassItems =
            PyClassItems { methods: &[], slots: &[] };
        PyClassItemsIter::new(&INTRINSIC_ITEMS, collector.py_methods())
    }
    fn doc(py: ::pyo3::Python<'_>)
        -> ::pyo3::PyResult<&'static ::std::ffi::CStr> {
        use ::pyo3::impl_::pyclass::*;
        static DOC:
            ::pyo3::sync::GILOnceCell<::std::borrow::Cow<'static,
            ::std::ffi::CStr>> =
            ::pyo3::sync::GILOnceCell::new();
        DOC.get_or_try_init(py,
                ||
                    {
                        let collector = PyClassImplCollector::<Self>::new();
                        build_pyclass_doc(<Self as ::pyo3::PyTypeInfo>::NAME, c"",
                            collector.new_text_signature())
                    }).map(::std::ops::Deref::deref)
    }
    fn lazy_type_object()
        -> &'static ::pyo3::impl_::pyclass::LazyTypeObject<Self> {
        use ::pyo3::impl_::pyclass::LazyTypeObject;
        static TYPE_OBJECT: LazyTypeObject<Array> = LazyTypeObject::new();
        &TYPE_OBJECT
    }
}
#[doc(hidden)]
#[allow(non_snake_case)]
impl Array { }
impl Array {
    #[doc(hidden)]
    pub const _PYO3_DEF: ::pyo3::impl_::pymodule::AddClassToModule<Self> =
        ::pyo3::impl_::pymodule::AddClassToModule::new();
}
#[doc(hidden)]
#[allow(non_snake_case)]
impl Array { }

impl Array {
    fn new(values: Vec<f64>) -> Self { Self(values) }

    fn mean(&self) -> f64 { stat::mean(&self.0) }

    fn stddev(&self) -> f64 { stat::stddev(&self.0) }
}
#[allow(unknown_lints, non_local_definitions)]
impl ::pyo3::impl_::pyclass::PyMethods<Array> for
    ::pyo3::impl_::pyclass::PyClassImplCollector<Array> {
    fn py_methods(self) -> &'static ::pyo3::impl_::pyclass::PyClassItems {
        static ITEMS: ::pyo3::impl_::pyclass::PyClassItems =
            ::pyo3::impl_::pyclass::PyClassItems {
                methods: &[::pyo3::impl_::pyclass::MaybeRuntimePyMethodDef::Static(::pyo3::impl_::pymethods::PyMethodDefType::Method(::pyo3::impl_::pymethods::PyMethodDef::noargs(c"mean",
                                        {
                                            unsafe extern "C" fn trampoline(_slf:
                                                    *mut ::pyo3::ffi::PyObject,
                                                _args: *mut ::pyo3::ffi::PyObject)
                                                -> *mut ::pyo3::ffi::PyObject {
                                                unsafe {
                                                    ::pyo3::impl_::trampoline::noargs(_slf, _args,
                                                        Array::__pymethod_mean__)
                                                }
                                            }
                                            trampoline
                                        }, c"mean($self)\n--\n\n"))),
                            ::pyo3::impl_::pyclass::MaybeRuntimePyMethodDef::Static(::pyo3::impl_::pymethods::PyMethodDefType::Method(::pyo3::impl_::pymethods::PyMethodDef::noargs(c"stddev",
                                        {
                                            unsafe extern "C" fn trampoline(_slf:
                                                    *mut ::pyo3::ffi::PyObject,
                                                _args: *mut ::pyo3::ffi::PyObject)
                                                -> *mut ::pyo3::ffi::PyObject {
                                                unsafe {
                                                    ::pyo3::impl_::trampoline::noargs(_slf, _args,
                                                        Array::__pymethod_stddev__)
                                                }
                                            }
                                            trampoline
                                        }, c"stddev($self)\n--\n\n")))],
                slots: &[::pyo3::ffi::PyType_Slot {
                                slot: ::pyo3::ffi::Py_tp_new,
                                pfunc: {
                                            unsafe extern "C" fn trampoline(subtype:
                                                    *mut ::pyo3::ffi::PyTypeObject,
                                                args: *mut ::pyo3::ffi::PyObject,
                                                kwargs: *mut ::pyo3::ffi::PyObject)
                                                -> *mut ::pyo3::ffi::PyObject {
                                                #[allow(unknown_lints, non_local_definitions)]
                                                impl ::pyo3::impl_::pyclass::PyClassNewTextSignature<Array>
                                                    for ::pyo3::impl_::pyclass::PyClassImplCollector<Array> {
                                                    #[inline]
                                                    fn new_text_signature(self)
                                                        -> ::std::option::Option<&'static str> {
                                                        ::std::option::Option::Some("(values)")
                                                    }
                                                }
                                                ::pyo3::impl_::trampoline::newfunc(subtype, args, kwargs,
                                                    Array::__pymethod___new____)
                                            }
                                            trampoline
                                        } as ::pyo3::ffi::newfunc as _,
                            }],
            };
        &ITEMS
    }
}
#[doc(hidden)]
#[allow(non_snake_case)]
impl Array {
    unsafe fn __pymethod___new____(py: ::pyo3::Python<'_>,
        _slf: *mut ::pyo3::ffi::PyTypeObject,
        _args: *mut ::pyo3::ffi::PyObject,
        _kwargs: *mut ::pyo3::ffi::PyObject)
        -> ::pyo3::PyResult<*mut ::pyo3::ffi::PyObject> {
        use ::pyo3::impl_::callback::IntoPyCallbackOutput;
        let function = Array::new;
        const DESCRIPTION:
            ::pyo3::impl_::extract_argument::FunctionDescription =
            ::pyo3::impl_::extract_argument::FunctionDescription {
                cls_name: ::std::option::Option::Some(<Array as
                        ::pyo3::type_object::PyTypeInfo>::NAME),
                func_name: "__new__",
                positional_parameter_names: &["values"],
                positional_only_parameters: 0usize,
                required_positional_parameters: 1usize,
                keyword_only_parameters: &[],
            };
        let mut output = [::std::option::Option::None; 1usize];
        let (_args, _kwargs) =
            DESCRIPTION.extract_arguments_tuple_dict::<::pyo3::impl_::extract_argument::NoVarargs,
                    ::pyo3::impl_::extract_argument::NoVarkeywords>(py, _args,
                    _kwargs, &mut output)?;
        #[allow(clippy :: let_unit_value)]
        let mut holder_0 =
            ::pyo3::impl_::extract_argument::FunctionArgumentHolder::INIT;
        let result =
            Array::new({
                    #[allow(unused_imports)]
                    use ::pyo3::impl_::pyclass::Probe as _;
                    ::pyo3::impl_::extract_argument::extract_argument::<_,
                                {
                                    ::pyo3::impl_::pyclass::IsOption::<Vec<f64>>::VALUE
                                }>(unsafe {
                                ::pyo3::impl_::extract_argument::unwrap_required_argument(output[0usize].as_deref())
                            }, &mut holder_0, "values")?
                });
        let initializer: ::pyo3::PyClassInitializer<Array> =
            result.convert(py)?;
        ::pyo3::impl_::pymethods::tp_new_impl(py, initializer, _slf)
    }
    unsafe fn __pymethod_mean__<'py>(py: ::pyo3::Python<'py>,
        _slf: *mut ::pyo3::ffi::PyObject)
        -> ::pyo3::PyResult<*mut ::pyo3::ffi::PyObject> {
        let function = Array::mean;
        #[allow(clippy :: let_unit_value)]
        let mut holder_0 =
            ::pyo3::impl_::extract_argument::FunctionArgumentHolder::INIT;
        let result =
            {
                let ret =
                    function(::pyo3::impl_::extract_argument::extract_pyclass_ref::<Array>(unsafe
                                        {
                                        ::pyo3::impl_::pymethods::BoundRef::ref_from_ptr(py, &_slf)
                                    }.0, &mut holder_0)?);
                {
                    let result =
                        {
                            let obj = ret;

                            #[allow(clippy :: useless_conversion)]
                            ::pyo3::impl_::wrap::converter(&obj).wrap(obj).map_err(::core::convert::Into::<::pyo3::PyErr>::into)
                        };
                    ::pyo3::impl_::wrap::converter(&result).map_into_ptr(py,
                        result)
                }
            };
        result
    }
    unsafe fn __pymethod_stddev__<'py>(py: ::pyo3::Python<'py>,
        _slf: *mut ::pyo3::ffi::PyObject)
        -> ::pyo3::PyResult<*mut ::pyo3::ffi::PyObject> {
        let function = Array::stddev;
        #[allow(clippy :: let_unit_value)]
        let mut holder_0 =
            ::pyo3::impl_::extract_argument::FunctionArgumentHolder::INIT;
        let result =
            {
                let ret =
                    function(::pyo3::impl_::extract_argument::extract_pyclass_ref::<Array>(unsafe
                                        {
                                        ::pyo3::impl_::pymethods::BoundRef::ref_from_ptr(py, &_slf)
                                    }.0, &mut holder_0)?);
                {
                    let result =
                        {
                            let obj = ret;

                            #[allow(clippy :: useless_conversion)]
                            ::pyo3::impl_::wrap::converter(&obj).wrap(obj).map_err(::core::convert::Into::<::pyo3::PyErr>::into)
                        };
                    ::pyo3::impl_::wrap::converter(&result).map_into_ptr(py,
                        result)
                }
            };
        result
    }
}

fn bind_pyo3(m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_function({
                    use mean as wrapped_pyfunction;
                    ::pyo3::impl_::pyfunction::WrapPyFunctionArg::wrap_pyfunction(m,
                        &wrapped_pyfunction::_PYO3_DEF)
                }?)?;
    m.add_function({
                    use stddev as wrapped_pyfunction;
                    ::pyo3::impl_::pyfunction::WrapPyFunctionArg::wrap_pyfunction(m,
                        &wrapped_pyfunction::_PYO3_DEF)
                }?)?;
    m.add_class::<Array>()
}
#[doc(hidden)]
mod bind_pyo3 {
    #[doc(hidden)]
    pub const __PYO3_NAME: &'static ::std::ffi::CStr = c"bind_pyo3";
    pub(super) struct MakeDef;
    #[doc(hidden)]
    pub static _PYO3_DEF: ::pyo3::impl_::pymodule::ModuleDef =
        MakeDef::make_def();
    #[doc(hidden)]
    pub static __PYO3_GIL_USED: bool = true;
    #[doc =
    r" This autogenerated function is called by the python interpreter when importing"]
    #[doc = r" the module."]
    #[doc(hidden)]
    #[export_name = "PyInit_bind_pyo3"]
    pub unsafe extern "C" fn __pyo3_init() -> *mut ::pyo3::ffi::PyObject {
        unsafe {
            ::pyo3::impl_::trampoline::module_init(|py|
                    _PYO3_DEF.make_module(py, true))
        }
    }
}
#[allow(unknown_lints, non_local_definitions)]
impl bind_pyo3::MakeDef {
    const fn make_def() -> ::pyo3::impl_::pymodule::ModuleDef {
        fn __pyo3_pymodule(module:
                &::pyo3::Bound<'_, ::pyo3::types::PyModule>)
            -> ::pyo3::PyResult<()> {
            bind_pyo3(::std::convert::Into::into(::pyo3::impl_::pymethods::BoundRef(module)))
        }
        const INITIALIZER: ::pyo3::impl_::pymodule::ModuleInitializer =
            ::pyo3::impl_::pymodule::ModuleInitializer(__pyo3_pymodule);
        unsafe {
            ::pyo3::impl_::pymodule::ModuleDef::new(bind_pyo3::__PYO3_NAME,
                c"", INITIALIZER)
        }
    }
}
