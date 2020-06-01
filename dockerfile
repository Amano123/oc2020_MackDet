FROM ubuntu:18.04
#fuck
LABEL maintainer="yooo"

#オープンキャンパス　マスク検出
ENV USER "oc2020_MackDet"
ENV HOME /home/${USER}
ENV DEBCONF_NOWARNINGS yes
ENV SHELL /usr/bin/zsh

# サーバー変更(しなくてもいい)
RUN sed -i 's@archive.ubuntu.com@ftp.jaist.ac.jp/pub/Linux@g' /etc/apt/sources.list

RUN set -x \
&&  apt-get update \
&&  apt upgrade -y --no-install-recommends\
&&  apt-get install -y --no-install-recommends \
                                        git \
                                        sudo \
                                        vim \
                                        zsh \
                                        #必要なパッケージはここから下に追加↓
                                        #python
                                        python3 \
                                        python3-pip \
                                        iputils-ping \
                                        ## network
                                        net-tools \
                                        ## japanese
                                        language-pack-ja-base \
                                        language-pack-ja \
                                        build-essential \
                                        cmake \
                                        checkinstall \
                                        ccache \
                                        libgtk-3-dev \
                                        libjpeg-dev \
                                        libpng++-dev \
                                        wget \
                                        unzip \
&&  apt-get -y clean \
&&  rm -rf /var/lib/apt/lists/* 

# USER
## 一般ユーザーアカウントを追加
RUN useradd -m ${USER} \
## 一般ユーザーにsudo権限を付与
&&  gpasswd -a ${USER} sudo \
## 一般ユーザーのパスワード設定
&&  echo "${USER}:maskmask" | chpasswd \
## sudo passを無くす
&&  echo "${USER} ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER

# python3 → python
RUN ln -s /usr/bin/python3 /usr/bin/python \
# pip3 → pip
&&  ln -s /usr/bin/pip3 /usr/bin/pip 
# 日本語化
RUN  locale-gen ja_JP.UTF-8 

#pythonライブラリ
RUN python3 -m pip --no-cache-dir install --upgrade pip \
&&  python3 -m pip --no-cache-dir install --upgrade setuptools \
&&  python3 -m pip --no-cache-dir install --upgrade \
                                            paddlehub \
                                            paddlepaddle \
                                            numpy \
                                            opencv-python 
                                            #必要なライブラリはここから下に追加↓

## zsh
COPY .zshrc /root/
COPY .zshrc ${HOME}

# 以降の作業ディレクトリを指定
WORKDIR ${HOME}

RUN wget https://github.com/opencv/opencv/archive/3.4.3.zip -O opencv-3.4.3.zip
RUN sudo apt install unzip
RUN unzip opencv-3.4.3.zip
RUN wget https://github.com/opencv/opencv_contrib/archive/3.4.3.zip -O opencv_contrib-3.4.3.zip
RUN unzip opencv_contrib-3.4.3.zip

COPY cmake.sh ${HOME}/opencv-3.4.3/

WORKDIR opencv-3.4.3/build/

RUN cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local \
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

# WORKDIR opencv-3.4.3/build
RUN sudo make -j4
RUN sudo make install
RUN sudo ldconfig

# 以降のRUN/CMDを実行するユーザー
USER ${USER}

CMD ["/bin/zsh"]
