#!/bin/sh
cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local \
-D WITH_OPENCL=OFF -D WITH_CUDA=OFF -D BUILD_opencv_gpu=OFF \
-D BUILD_opencv_gpuarithm=OFF -D BUILD_opencv_gpubgsegm=OFF \
-D BUILD_opencv_gpucodec=OFF -D BUILD_opencv_gpufeatures2d=OFF \
-D BUILD_opencv_gpufilters=OFF -D BUILD_opencv_gpuimgproc=OFF \
-D BUILD_opencv_gpulegacy=OFF -D BUILD_opencv_gpuoptflow=OFF \
-D BUILD_opencv_gpustereo=OFF -D BUILD_opencv_gpuwarping=OFF \
-D BUILD_DOCS=OFF -D BUILD_TESTS=OFF \
-D BUILD_PERF_TESTS=OFF -D BUILD_EXAMPLES=OFF \
-D BUILD_opencv_python3=ON -D FORCE_VTK=ON \
-D WITH_TBB=ON -D WITH_V4L=ON \
-D WITH_OPENGL=ON -D WITH_CUBLAS=ON \
-D BUILD_opencv_python3=ON \
-D PYTHON3_EXECUTABLE=`pyenv local 3.6.8; pyenv which python` \
-D PYTHON3_INCLUDE_DIR=`pyenv local 3.6.8; python -c 'from distutils.sysconfig import get_python_inc; print(get_python_inc())'` \
-D PYTHON3_NUMPY_INCLUDE_DIRS=`pyenv local 3.6.8; python -c 'import numpy; print(numpy.get_include())'` \
-D PYTHON3_LIBRARIES=`find $PYENV_ROOT/versions/3.6.8/lib -name 'libpython*.so'` \
-D WITH_FFMPEG=ON \
..