Bootstrap:docker
From:continuumio/miniconda3

#
# sudo singularity build rnatoy Singularity
#

%help
This is an example for a container that serves samtools, bowtie, and tophat
    and is intended (but not required) to run with a nextflow pipeline. The
    user can also take advantage of using the container for development, 
    or interaction with any of the individual steps in the pipeline.

    # List all apps
    ./rnatoy apps

    # Run a specific app
    ./rnatoy run <app>

    # Execute primary runscript
    ./rnatoy

    # Loop over all apps
    for app in $(./rnatoy apps); do
        ./rnatoy run $app
    done


%runscript
    exec /opt/conda/bin/scif "$@"

%files
    rnatoy.scif
    helpers.scif
    nextflow-docker.config
    nextflow-singularity.config
    
%post
    # Dependencies
    apt-get update && apt-get install -y wget \
                                         unzip \
                                         apt-utils \
                                         python      # tophat needs v2.

    # Install scif from pypi
    /opt/conda/bin/pip install scif

    # Install the filesystem from the recipe
    /opt/conda/bin/scif install /rnatoy.scif
    /opt/conda/bin/scif install /helpers.scif
