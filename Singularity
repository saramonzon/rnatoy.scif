Bootstrap:docker
From:pditommaso/dkrbase:1.2

#
# sudo singularity build rnaseq Singularity
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
    exec /usr/local/bin/scif "$@"

%files
    rnatoy.scif
    data
    
%post
    apt-get update --fix-missing && \
    apt-get install -q -y samtools python && \
    wget https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py

    # Install scif from pypi
    /usr/local/bin/pip install scif

    # Install the filesystem from the recipe
    scif install /rnatoy.scif
