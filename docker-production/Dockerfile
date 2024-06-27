#
# ***** BEGIN LICENSE BLOCK *****
# 
# Copyright (C) 2023 Olof Hagsand
#
# This file is part of CLIXON
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# ***** END LICENSE BLOCK *****
#

FROM debian:bookworm-slim
MAINTAINER Kristofer Hallin <kristofer@sunet.se>

RUN apt update
RUN apt install -y procps emacs-nox git make gcc bison libnghttp2-dev libssl-dev flex python3 python3-pip sudo sshpass

RUN mkdir /clixon
WORKDIR /clixon

RUN git clone https://github.com/clicon/cligen.git
RUN git clone https://github.com/clicon/clixon.git
RUN git clone https://github.com/clicon/clixon-controller.git
RUN git clone https://github.com/clicon/clixon-pyapi.git

RUN (cd cligen; git checkout 38b24acbc30cec1b13277b2a7ac1782a0ae441f0)
RUN (cd clixon; git checkout 9738345f828e15eae6dafd52980da564e882694e)
RUN (cd clixon-controller; git checkout 172d6aca7cbd01eb76a07c950eed68f5ba9f325e)

RUN useradd -m -d /home/clicon clicon
RUN ls -l /home

WORKDIR /clixon/cligen
RUN ./configure
RUN make
RUN make install
RUN ldconfig

WORKDIR /clixon/clixon
RUN ./configure
RUN make
RUN make install
RUN ldconfig

# Copy Clixon-controller code from local dir
WORKDIR /clixon/clixon-controller
RUN ./configure
RUN make
RUN make install
RUN ldconfig

WORKDIR /clixon/clixon-pyapi
RUN python3 setup.py install
RUN cp clixon_server.py /usr/local/bin/

#USER clicon
RUN pip3 install -r requirements.txt --break-system-packages

USER root
WORKDIR /clixon
RUN pip3 install -r clixon-pyapi/requirements.txt --break-system-packages
RUN cp /usr/local/etc/clixon/controller.xml /usr/local/etc/clixon/clixon.xml
RUN cp /usr/local/etc/clixon/controller.xml /usr/local/etc/clixon.xml

COPY startsystem.sh /usr/local/bin/

ENTRYPOINT /usr/local/bin/startsystem.sh
