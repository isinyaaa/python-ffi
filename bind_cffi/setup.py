from setuptools import Extension, setup

setup(
    ext_modules=[
        Extension(
            "_rs_stat",
            sources=[
                "_cffi.c",
            ],
            libraries=[
                "bind_c",
            ],
            library_dirs=[
                "src/bind_cffi",
            ],
            runtime_library_dirs=[
                "bind_cffi",
            ],
        )
    ]
)

# ext-modules = [
#     { name = "_rs_stat",  },
# ] # packages = ["traditional"]
