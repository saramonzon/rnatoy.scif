# RNA-Seq toy pipeline 

[![nextflow](https://img.shields.io/badge/nextflow-%E2%89%A50.24.0-brightgreen.svg?style=for-the-badge)](http://nextflow.io)
[![scif](https://img.shields.io/badge/filesystem-scientific-green.svg?style=for-the-badge)](https://sci-f.github.io)

A proof of concept of a RNA-Seq pipeline. Here we are (trying to) combine three technologies to handle each of the following:

 - **Reproducibility** of software is handled by Singularity
 - **Discoverability** and **Transparency** are handled by installing our software in the container via a [Scientific Filesystem](https://sci-f.github.io). SCIF also lets us install the same dependencies across container technologies.

and **workflow** should be handled by NextFlow, but I can't get it working.

Each of these components plays a slightly different and equally important role. Without Nextflow, we can generate a reproducible pipeline with modular, discoverable entry points to the container, and execute the commands manually without a complicated configuration file. See an [example here](https://github.com/vsoch/carrierseq/blob/master/docs/docker.scif.md#carrierseq-pipeline). Without SCIF, we could have the same container with commands to execute known software inside, but the container would largely remain a black box with software mixed amongst the base operating system. If I used the Nextflow container without the Nextflow pipeline, it would be a black box. For any container with a single entrypoint and no clear way to inspect the executables intended for use inside, we have a mystery. Without Singularity you could use a Docker container or install software on your host, but (as we all know) this would likely not be a portable solution. Thus, for now, these two technologies...

Scientific Filesystem :blue_heart: Containers

And I'd like to add Nextflow to that list, if it works. If you don't need to run on a shared resource, the Container could be Docker. If you need to, it should be Singularity.

**Note that I haven't figured out Nextflow yet, but show the simple commands to run with a container and SCIF. For details on the various files, keep reading. For the original source code, see the [src](src) folder for the example from [nextflow.io](https://www.github.com/nextflow.io/rnatoy). The example uses Docker and Singularity containers to run the pipeline, but without SCIF.


# Recipes
What are we looking at in the repository? When building pipelines, you can think of it like baking a cake. We have entire recipes for creating our final products (containers), and within those recipes ingredients (software) that we need to add. In this first part, we will talk about the three recipes in this repository, the [Dockerfile](Dockerfile) for the Docker container, the [Singularity](Singularity) recipe for a Singularity container, and the [rnatoy.scif](rnatoy.scif) recipe 

## The Scientific Filesystem Recipe
A scientific filesystem is useful because it allows me to write one recipe for my various software, and then install easily in different containers or on my host. How do you know when you find a recipe? When you find a recipe for a scientific filesystem (SCIF), you will see a file with extension *.scif. For example, in this repository:

 - [rnatoy.scif](rnatoy.scif) is the recipe for the scientific filesystem that will be installed in both the Docker and Singularity containers to be run with nextflow. SCIF is flexible in that there are **many** different internal applications defined in this one file, however if we wanted we could put them in individual files and install them equivalently. For example, given the apps "samtools" "tophat" and "bowtie" and using a single recipe file `rnatoy.scif`, I would install like:

```
/usr/local/bin/scif install rnatoy.scif
```
but I could also define the different applications in separate files, and these commands would give me the same result.

```
/usr/local/bin/scif install samtools.scif
/usr/local/bin/scif install bowtie.scif
/usr/local/bin/scif install tophat.scif
```

This level of modularity is up to the user. For this repository, I've decided to provide the core applications in [rnatoy.scif](rnatoy.scif), and then a set of helpers in [helpers.scif](helpers.scif). Programatically, this install would be equivalent. Some might argue two files are not better than one. This is a purely "human information" decision - I want my users to know easily what is core software, and what are helpers. If I am building a single container to share with my paper, I would opt for the first to only need one file. If I am providing a builder service to users and want to easily install recipes in a modular fashion, I would want to do the second.

This means that, for any SCIF recipe and a host of interest (Docker or Singularity container, or your computer) you can install the same recipes. [Take a look now](rnatoy.scif) at the 


## The Docker Recipe
If you are familar with Docker, you will know that the [Dockerfile](Dockerfile) is the recipe for building our container. You will also notice the installation is simple - we start with a container base that was equivalently used by the creator of the pipeline with system / host dependencies, and then simply install the SCIF recipe to it. That comes down to these three commands:

```
RUN /usr/local/bin/pip install scif         # Install scif from pypi
ADD rnatoy.scif /                           # Add the recipe to the container
RUN scif install /rnatoy.scif               # Install it to the container
```

We could build this via an automated build by connecting it to Docker Hub (so other users don't need to also build the container locally) or we can build locally ourselves:

```
docker build -t vanesa/rnatoy .
```

## The Singularity Recipe
The recipe file for a Singularity container is the file [Singularity](Singularity). The format of the recipe file is differnet, but installing the scientific filesystem, again from the recipe [rnatoy.scif](rnatoy.scif) comes down to the same commands:

```
/usr/local/bin/pip install scif         # Install scif from pypi
scif install /rnatoy.scif               # Install it to the container
```

The only missing command to add the recipe to the container is because Singularity recipes allow you to do this in a `%files` section.

```
%files
    rnatoy.scif
```

Then you could again push to your Github repository, connect the repository to Singularity Hub, or just build locally:

```
sudo singularity build rnatoy Singularity
```

# The Scientific Filesystem
For each of the following examples, we show commands with Docker and with a Singularity container called `rnatoy`. If we want to interact with our filesystem, we can just run the container:

```
$ docker run vanessa/rnatoy
$ ./rnatoy
```
```
Scientific Filesystem [v0.0.71]
usage: scif [-h] [--debug] [--quiet] [--writable]
            
            {version,pyshell,shell,preview,help,install,inspect,run,apps,dump,exec}
            ...

scientific filesystem tools

optional arguments:
  -h, --help            show this help message and exit
  --debug               use verbose logging to debug.
  --quiet               suppress print output
  --writable, -w        for relevant commands, if writable SCIF is needed

actions:
  actions for Scientific Filesystem

  {version,pyshell,shell,preview,help,install,inspect,run,apps,dump,exec}
                        scif actions
    version             show software version
    pyshell             Interactive python shell to scientific filesystem
    shell               shell to interact with scientific filesystem
    preview             preview changes to a filesytem
    help                look at help for an app, if it exists.
    install             install a recipe on the filesystem
    inspect             inspect an attribute for a scif installation
    run                 entrypoint to run a scientific filesystem
    apps                list apps installed
    dump                dump recipe
    exec                execute a command to a scientific filesystem
```

## Inspecting Applications
The strength of SCIF is that it will always show you the applications installed in a container, and then provide predictable commands for inspecting, running, or otherwise interacting with them. For example, if I find the container, without any prior knowledge I can reveal the applications inside:

```
$ docker run vanessa/rnatoy apps
$ ./rnatoy apps
```
```
    bowtie
 cufflinks
    tophat
  samtools
nextflow-docker-config
nextflow-singularity-config
```

The last two were installed from [helpers.scif](helpers.scif), and the first two from [rnatoy.scif](rnatoy.scif). We can look at an application in detail, including asking for help:

```
$ docker run vanessa/rnatoy help samtools
$ ./rnatoy help samtools
```
```
    This app provides Samtools suite
```

and then inspecting

```
$ docker run vanessa/rnatoy inspect samtools
$ ./rnatoy inspect samtools
```
```
{
    "samtools": {
        "apprun": [
            "    exec /usr/bin/samtools \"$@\""
        ],
        "apphelp": [
            "    This app provides Samtools suite"
        ],
        "applabels": [
            "VERSION 1.7",
            "URL http://www.htslib.org/"
        ]
    }
}
```

The creator of the container didn't write any complicated scripts to have this happen - the help text is just a chunk of text in a block of the recipe. The labels that are parsed to json, are also just written easily on two lines. This means that the creator can spend less time worry about exposing this. If you can write a text file, you can make your applications programatically parseable.

## Interacting with Applications
I can easily shell into the container in the context of an application, meaning that the
environment is sourced, etc. 

```
$ docker run -it vanessa/rnatoy shell samtools
$ ./rnatoy shell samtools
```
```
[samtools] executing /bin/bash 
root@d002e338b88b:/scif/apps/samtools# env | grep PATH
LD_LIBRARY_PATH=/scif/apps/samtools/lib
PATH=/scif/apps/samtools/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```

Notice how I'm in the app's context (in it's application folder) and that it's bin is added to the path? I can also shell in without a specific application context, but still have all the SCIF [global variables](https://sci-f.github.io/spec-v1#environment-namespace) available to me.

```
$ docker run -it vanessa/rnatoy shell
$ ./rnatoy shell
```
```
WARNING No app selected, will run default ['/bin/bash']
executing /bin/bash 
root@055a34619d17:/scif# ls
apps
data
```

The same kind of functionality exists with the python shell, `pyshell`, but you interact directly with the scif client:

```
$ docker run -it vanessa/rnatoy pyshell
$ ./rnatoy pyshell
```
```
Found configurations for 6 scif apps
cufflinks
samtools
bowtie
tophat
nextflow-docker-config
nextflow-singularity-config
[scif] /scif cufflinks | samtools | bowtie | tophat | nextflow-docker-config | nextflow-singularity-config
Python 3.6.2 |Anaconda, Inc.| (default, Sep 22 2017, 02:03:08) 
[GCC 7.2.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
(InteractiveConsole)
client.apps()
['cufflinks', 'samtools', 'bowtie', 'tophat', 'nextflow-docker-config', 'nextflow-singularity-config']
```

## Running Applications
Before we get into creating a pipeline, look how easy it is to run an application. Without scif, we would have to have known that samtools is installed, and then executed the command to the container. But with the scientific filesystem, we discovered the app (shown above) and then we can just run it. The `run` command maps to the entrypoint, as was defined by the creator:

```
$ docker run vanessa/rnatoy run samtools
$ ./rnatoy run samtools
```
```
Program: samtools (Tools for alignments in the SAM format)
Version: 0.1.18 (r982:295)

Usage:   samtools <command> [options]

Command: view        SAM<->BAM conversion
         sort        sort alignment file
         mpileup     multi-way pileup
         depth       compute the depth
         faidx       index/extract FASTA
         tview       text alignment viewer
         index       index alignment
         idxstats    BAM index stats (r595 or later)
         fixmate     fix mate information
         flagstat    simple stats
         calmd       recalculate MD/NM tags and '=' bases
         merge       merge sorted alignments
         rmdup       remove PCR duplicates
         reheader    replace BAM header
         cat         concatenate BAMs
         targetcut   cut fosmid regions (for fosmid pool only)
         phase       phase heterozygotes

[samtools] executing /bin/bash /scif/apps/samtools/scif/runscript
```

And executing any command in the context of the application is possible too:

```
$ docker run vanessa/rnatoy exec samtools env | grep PATH
$ ./rnatoy exec samtools env | grep PATH
```
```
LD_LIBRARY_PATH=/scif/apps/samtools/lib
PATH=/scif/apps/samtools/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```

Note that for above, you will get more output with the Singularity container, as it shares the environment with the host. Whether we are using Docker or Singularity, the actions going on internally with the scientific filesystem client are the same. Given a simple enough pipeline, we could stop here, and just issue a series of commands to run the different apps.


## Run Using Docker + Scientific Filesystem
I'm having trouble getting nextflow to work, so here is how to run the steps using just SCIF with the container. For the following steps, scif ensures that `/scif/data` exists in the container, so we can use it as a working directory with confidence.


### Bowtie
Here is what we are starting with:

```
ls data/ggal
ggal_1_48850000_49020000.bed.gff               ggal_gut_1.fq  ggal_liver_1.fq
ggal_1_48850000_49020000.Ggal71.500bpflank.fa  ggal_gut_2.fq  ggal_liver_2.fq
```

and let's define what these paths will look like in the container. The /scif/data folder
that we know to exist with scif we will map to "data" in the present working directory.

```
genome=/scif/data/ggal_1_48850000_49020000.Ggal71.500bpflank.fa
genomeIndex=${genome}.index
```
```
docker run -v $PWD/data/ggal:/scif/data vanessa/rnatoy exec bowtie bowtie2-build --threads 1 $genome $genomeIndex
singularity run -B $PWD/data/ggal:/scif/data rnatoy exec bowtie bowtie2-build --threads 1 $genome $genomeIndex
```

In the above, notice that I am:

 1. defining a genome and index output to be in the /scif/data folder in the container
 2. which is mapped to my host $PWD/data folder that has the data files

The output is verbose, but I get the result on my local machine!

```
ls data/ggal/
ggal_1_48850000_49020000.bed.gff                           ggal_1_48850000_49020000.Ggal71.500bpflank.fa.index.3.bt2      ggal_gut_1.fq
ggal_1_48850000_49020000.Ggal71.500bpflank.fa              ggal_1_48850000_49020000.Ggal71.500bpflank.fa.index.4.bt2      ggal_gut_2.fq
ggal_1_48850000_49020000.Ggal71.500bpflank.fa.index.1.bt2  ggal_1_48850000_49020000.Ggal71.500bpflank.fa.index.rev.1.bt2  ggal_liver_1.fq
ggal_1_48850000_49020000.Ggal71.500bpflank.fa.index.2.bt2  ggal_1_48850000_49020000.Ggal71.500bpflank.fa.index.rev.2.bt2  ggal_liver_2.fq
```

### Tophat
Now let's do the next step, and we will do the same sort of deal. Note I'm not sure if I am executing this correctly, I've never used tophat.

```
reads="/scif/data/ggal_gut_1.fq /scif/data/ggal_gut_2.fq /scif/data/ggal_liver_1.fq /scif/data/ggal_liver_2.fq"
annot=/scif/data/ggal_1_48850000_49020000.bed.gff
```
```
docker run -v $PWD/data/ggal:/scif/data vanessa/rnatoy exec tophat tophat2 -p 1 --GTF $annot $genomeIndex $reads
singularity run -B $PWD/data/ggal:/scif/data rnatoy exec tophat tophat2 -p 1 --output-dir /scif/data --GTF $annot $genomeIndex $reads
```

### Cufflinks

Finally, this one!

```
bam_file=/scif/data/unmapped.bam
```
```
docker run -v $PWD/data/ggal:/scif/data vanessa/rnatoy exec cufflinks cufflinks --no-update-check -q -p 1 -G $annot $bam_file
singularity run -B $PWD/data/ggal:/scif/data rnatoy exec cufflinks cufflinks --no-update-check -q -p 1 -G $annot $bam_file
```

I don't think that was right (There are two bam files, accepted_hits and unmapped and I have no idea?), but I can't spend more time on this! Note that the rest of this description is wrong, I can't figure out for the life of me how Nextflow works. I'm going to try other workflow managers instead.


# Summary
I'd really like this to work with Nextflow - I spent all weekend on it, and at this point it seems forceful or even extra to try and make it work. I'll leave it at that.


# Nextflow
It's commonly the case that your application has many more complicated runtime variables, or binds, and you want to be able to define these variables in one place, and then execute the workflow. You want step 2 to wait for step 1, and to not be run if there is a missing dependency. This is where Nextflow comes in! For this example, if you wanted you could install the nextflow controller on your host:

```
curl -fsSL get.nextflow.io | bash
```

You can also use a container! In this case I'm going to use Singularity so that my home (and the recipe file I'm interacting with) is mounted by default. I could just "run" this, but instead I'd prefer to pull it:

```
singularity pull --name nextflow  docker://nextflow/nextflow
./nextflow
```
Note that you need bash and Java 8 installed for this to work.

## Configuration
Nextflow has a [configuration file](https://www.nextflow.io/docs/latest/config.html) that by default is named `nextflow.config`, and is combined with a user's "global" file in their `$HOME` directory. For this example, since we have a configuration file for each of Docker and Singularity, we are going to take advantage of defining a custom configuration file at runtime.

```
./nextflow run -C <config file>.
```

How can we make sure that our exact configuration, or that a template for it, is provided with our work? Including the files in the same version controlled repository is good. But what if they get separated? We have provided the user with applications in the container to generate the configuration files, for each of Singularity and Docker:

```
$ docker run vanessa/rnatoy apps | grep config
nextflow-docker-config
nextflow-singularity-config
```

Get help, because you don't remember what this is:

```
docker run vanessa/rnatoy help nextflow-docker-config
    Run this application to get the nextflow.config recipe printed to the screen
    for running the Pipeline with Nextflow and Docker
        ./rnatoy --quiet run nextflow-docker-config >> nextflow.config
```

Do the suggested command to save the nextflow configuration file to your `$PWD`. Note that "quiet" is added to suppress additional output, and the command below is using Docker while the help shows a general "container" executable called `rnatoy`.

```
$ docker run vanessa/rnatoy run nextflow-docker-config >> nextflow-docker.config
```

If you were customizing the data, you would edit this configuration file now. We are going to use the defaults (data provided from S3).


## Run NextFlow
Enough with configuration and recipes! Let's run this thing. Here we are going to specify the Docker configuration, and our Docker container. This is an interesting setup because our nextflow executable is a Singularity container.


```
./nextflow -C nextflow-docker.config run main.nf  -with-docker
```

and if we specify the `docker.enabled = true` in the configuration file, we can remove that too:

```
./nextflow -C nextflow-docker.config run main.nf
```

How does it work? The line to execute just one command to bowtie, for example, would mean running the exec statement in the context of the applicaition, e.g.,:

```
docker run -it vanessa/rnatoy exec bowtie which bowtie2-build
[bowtie] executing /usr/bin/which bowtie2-build
/scif/apps/bowtie/bin/bowtie2-build
```

So thus, we change the running line in the [main.nf](main.nf) from:

```
bowtie2-build --threads ${task.cpus} ${genome} genome.index
```

to:

```
exec bowtie bowtie2-build --threads ${task.cpus} ${genome} genome.index
```


## Additions / Notes:
These are additional notes that I will write up in more detail.

 - note the modular nature of the apps, I can now know that the container has bowtie, samtools, without seeing the recipe or listing executables on the path.
 - software install goes into respective bins of the application folder. Before we were installing to opt, and had to add these to the path.
 - I added `python-setuptools` to install scif from PyPi.
 - Note that for some software, I chose to install from source code in the /scif base, because I can then make a strong assumption that the files there belong to the software. But let's say that I for some reason want to use the system package manager, but still reveal the executable as a scif entrypoint? The apps here show this example with samtools. I define the entry point to execute it.
 - I can package the nextflow config and pipeline WITH the container, as an app. Then give the user instructions to use it!

The original code, to build "the same" Docker and Singularity containers, took the build strategy of:

```
Dockerfile --> Dockerhub --> Docker Image
               Dockerhub --> Singularity Recipe --> Singularity Container
```

but we can do (and are providing example for here:

```
SCIF Recipe --> Dockerfile --> Dockerfile --> Docker Image
            --> Singularity Recipe --> Singularity Container

```

I personally like the first because it's faster to dump Docker layers into a Singularity image than waiting through the entire installation steps again. However, you can imagine having two separate (automated) builds that both depend on some source. If we depend on the Docker Hub build, we can't make them start at the same trigger (the Github commit). But if we have the builds trigger from the Github commit and then proceed with just the updated SCIF recipe, this won't break.


## Development
During the development of the container, I took a strategy to start with a base, interactively shell into it, and test installation and running of things. To do that you might want to build the container first from the Dockerfile, or Singularity recipe.

```
docker build -t vanessa/rnatoy .
sudo singuarity build rnatoy Singularity
```

then shell inside

```
docker run -it --entrypoint bash vanessa/rnatoy

sudo singularity build --sandbox [rnatoy] Singularity
sudo singularity shell --writable [rnatoy]
```

## Thinking
Now imagine that we can build these containers on Singularity Hub (or similar registry) and extract the SCIF apps. At first I was worried about not having a definitive namespace for the apps. What if two users created two different labels for "samtools" ? However, this might actually be a better way, because (in my opinion) I don't think there is, or ever can be, a "best way" to do something. The first reason is because the answer is largely dependent on the goals and context for accomplishing the task. The second reason is because technology changes so quickly, the idea of "best" is the wrong one to have, period. Rather, we can view duplictes of the same thing not as dangerous or wrong, but as instances that each serve as a researchre's best effort to accomplish some task. If we have many of these instances, then we suddently can do things like evaluate common features that are associated with a goal or question of interest, or a level of performance. If we start to think of our software, and various versions of it, as a sampling space, this "problem" of not identifying an exact version or "best" becomes a lot more fun, useful, and interesting.
