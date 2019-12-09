FROM ubuntu:18.04 as builder

USER root

# Locale
ENV LC_ALL C
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

# ALL tool versions used by opt-build.sh
ENV VER_NUMPY="1.17.4"
ENV VER_SCIPY="1.3.3"
ENV VER_MAGECK="0.5.9.2"

RUN apt-get -yq update
RUN apt-get install -yq \ 
python3-pip \
python3-dev \
curl 

RUN pip3 install --upgrade pip

ENV OPT /opt/wsi-t113
ENV PATH $OPT/bin:$PATH
ENV LD_LIBRARY_PATH $OPT/lib

ADD build/opt-build.sh build/
RUN bash build/opt-build.sh $OPT

FROM ubuntu:18.04 

LABEL maintainer="vo1@sanger.ac.uk" \
      version="1.0.0" \
      description="MAGeCK container"

MAINTAINER  Victoria Offord <vo1@sanger.ac.uk>

RUN apt-get -yq update
RUN apt-get install -yq --no-install-recommends \
python3 \
python3-distutils \
libcurl4

ENV OPT /opt/wsi-t113
ENV PATH $OPT/bin:$OPT/python3/bin:$PATH
ENV LD_LIBRARY_PATH $OPT/lib
ENV PYTHONPATH $OPT/python3:$OPT/python3/lib/python3.6/site-packages
ENV LC_ALL C
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV DISPLAY=:0

RUN mkdir -p $OPT
COPY --from=builder $OPT $OPT

#Create some usefull symlinks
RUN cd /usr/local/bin && \
    ln -s /usr/bin/python3 python

## USER CONFIGURATION
RUN adduser --disabled-password --gecos '' ubuntu && chsh -s /bin/bash && mkdir -p /home/ubuntu

USER ubuntu
WORKDIR /home/ubuntu

CMD ["/bin/bash"]
