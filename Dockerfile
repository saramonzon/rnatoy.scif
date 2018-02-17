FROM pditommaso/dkrbase:1.2

###############################################
# SciF Base
#
# docker build -t vanessa/rnatoy .
# docker run vanessa/rnatoy
#
###############################################

RUN apt-get update --fix-missing && \
  apt-get install -q -y samtools python && \
  wget https://bootstrap.pypa.io/get-pip.py && \
  python get-pip.py

# Install scif from pypi
RUN /usr/local/bin/pip install scif

# Install the filesystem from the recipe
ADD *.scif /
ADD nextflow-*.config /
RUN scif install /helpers.scif
RUN scif install /rnatoy.scif

# SciF Entrypoint
ENTRYPOINT ["scif"]
