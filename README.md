# mg5-standalone

This project containers a Docker setup for MadGraph including a model for top-philic resonances.
It allows for fast generation of truth-level events without detector simulation (or using Delphes as a parametrisation of the ATLAS detector).

The software is provided as a docker image which is hosted on Docker Hub at [philippgadow/mg5-standalone](https://hub.docker.com/repository/docker/philippgadow/mg5-standalone).

## Usage:
### Docker
On a local machine with Docker installed (e.g. your laptop), execute:
```
mkdir output
docker run -it --rm --volume $PWD/output:/var/MG_outputs philippgadow/mg5-standalone
# ignore warning about groups if it pops up
# groups: cannot find name for group ID 1099333925
```

### Singularity (e.g. on DESY NAF)
On a machine with singularity support execute:
```
singularity exec --contain --bind /afs:/afs  --bind /nfs:/nfs docker://philippgadow/mg5-standalone bash
# this will download the image and cache it at ~/.singularity/cache/oci-tmp/
# ignore warning about groups: cannot find name for group ID 1099333925

# inside the container both /afs and /nfs are mounted, allowing you to create directories in your afs space
mkdir ~/mg5_output
cd ~/mg5_output

# launch mg5 with default event generation for top-philic resonances model
/home/hep/MG5_aMC_v2_7_3/bin/mg5_aMC /home/hep/commands/generate_v1_mv1_1000_wv1_auto.cmnd
```

Alternatively, you can download ("pull") the image to a local path to avoid caching it in your afs space.
This results in better performance.
```
# example, adapt paths accordingly
singularity build --sandbox /nfs/dust/atlas/user/pgadow/bsm4top/containers/mg5-standalone docker://philippgadow/mg5-standalone
# wait until image is prepared, then launch container from local image
singularity exec --contain --bind /afs:/afs  --bind /nfs:/nfs /nfs/dust/atlas/user/pgadow/bsm4top/containers/mg5-standalone bash
```

