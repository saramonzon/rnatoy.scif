# RNA-Seq toy pipeline 

A proof of concept of a RNA-Seq pipeline. Here we are combining three technologies to handle each of the following:

 - **Workflow** is handled by Nextflow, along with reproducibility of the workflow.
 - **Reproducibility** of software is handled by Singularity
 - **Discoverability** and **Transparency** are handled by installing our software in the container via a [Scientific Filesystem](https://sci-f.github.io). SCIF also lets us install the same dependencies across container technologies.

[![nextflow](https://img.shields.io/badge/nextflow-%E2%89%A50.24.0-brightgreen.svg)](http://nextflow.io)
[![scif](https://img.shields.io/badge/scientific-filesystem-brightgreen.svg)](https://sci-f.github.io)

Each of these components plays a slightly different and equally important role. Without Nextflow, we could generate a reproducible pipeline with modular, discoverable entry points to the container, but we would need to execute the commands manually. See an [example here](https://github.com/vsoch/carrierseq/blob/master/docs/docker.scif.md#carrierseq-pipeline). Without SCIF, we could have the same container with commands to execute known software inside, but the container would largely remain a black box with software mixed amongst the base operating system. If you found it after the fact, it would be a mystery. Without Singularity you could use a Docker container or install software on your host, but (as we all know) this would likely not be a portable solution. I might say that these three technologies...

![]()

and if you don't need to run on a shared resource? Then we have this:

![]()


How execute it
----------------

1) Install Docker on your computer. Read more here https://docs.docker.com/

2) Install Nextflow (version 0.24.x or higher)

    `curl -fsSL get.nextflow.io | bash`

3) Pull the required Docker image as shown below: 

    `docker pull nextflow/rnatoy:1.3`


4) Launch the pipeline execution: 

    `nextflow run nextflow-io/rnatoy -with-docker` 
    
    
