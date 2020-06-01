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
                                        #python
                                        python3 \
                                        python3-pip \
                                        iputils-ping \
                                        ## network
                                        net-tools \
                                        ## japanese
                                        language-pack-ja-base \
                                        language-pack-ja \
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

## zsh
COPY .zshrc /root/
COPY .zshrc ${HOME}

# 以降のRUN/CMDを実行するユーザー
USER ${USER}

# 以降の作業ディレクトリを指定
WORKDIR ${HOME}

CMD ["/bin/zsh"]
