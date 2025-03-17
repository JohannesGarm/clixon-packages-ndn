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
RUN apt install -y procps emacs-nox git make gcc bison libnghttp2-dev libssl-dev flex python3 python3-pip sudo sshpass bgpq4

RUN mkdir ~/.ssh
COPY ssh/id_rsa /root/.ssh/id_rsa
COPY ssh/config /root/.ssh/config

RUN mkdir /clixon
WORKDIR /clixon

RUN git clone https://github.com/clicon/cligen.git
RUN git clone https://github.com/clicon/clixon.git
RUN git clone https://github.com/clicon/clixon-controller.git
RUN git clone https://github.com/clicon/clixon-pyapi.git

RUN (cd cligen; git checkout a00f14e19c42b2b418f2259e51f98df2ec528fe3)
RUN (cd clixon; git checkout 411f509fd867344d2bf7aa1e740e892a4d4ef90a)
RUN (cd clixon-controller; git checkout 3a641a9d1f7f5027e518250675711d56c4eee3be)
RUN (cd clixon-pyapi; git checkout b85c8ec5d68953717cee181e1194ed8991e1003d)

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
RUN pip3 install --break-system-packages requests

USER root
WORKDIR /clixon
RUN pip3 install -r clixon-pyapi/requirements.txt --break-system-packages
RUN cp /usr/local/etc/clixon/controller.xml /usr/local/etc/clixon/clixon.xml
RUN cp /usr/local/etc/clixon/controller.xml /usr/local/etc/clixon.xml


WORKDIR /clixon/clixon-controller
RUN cd extensions/plugins; make; make install; ldconfig

WORKDIR /clixon
COPY startsystem.sh /usr/local/bin/

ENTRYPOINT /usr/local/bin/startsystem.sh
