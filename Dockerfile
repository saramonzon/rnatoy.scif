FROM continuumio/miniconda3

###############################################
# SciF Base
#
# docker build -t vanessa/rnatoy .
# docker run vanessa/rnatoy
#
###############################################

# Dependencies
RUN apt-get update && apt-get install -y wget \
                                         unzip \
                                         apt-utils \
                                         python      # tophat needs v2.

# Install scif from pypi
RUN /opt/conda/bin/pip install scif

# Install the filesystem from the recipe
ADD *.scif /
ADD nextflow-*.config /
RUN scif install /helpers.scif
RUN scif install /rnatoy.scif

# SciF Entrypoint
ENTRYPOINT ["scif"]
