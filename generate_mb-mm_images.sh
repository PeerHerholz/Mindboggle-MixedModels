#Generate Dockerfile.

#!/bin/sh

 set -e

 # Generate Dockerfile.
generate_docker() {
  docker run --rm kaczmarj/neurodocker:0.5.0 generate docker \
             --base neurodebian:stretch-non-free \
             --pkg-manager apt \
             --miniconda \
                conda_install="python=3.6 numpy pandas sklearn-lmer scipy rpy2=2.9.4 r-lme4 r-lmertest r-emmeans tzlocal seaborn" \
                create_env='mb-mm' \
                activate=true
}

generate_singularity() {
  docker run --rm kaczmarj/neurodocker:0.5.0 generate singularity \
            --base neurodebian:stretch-non-free \
            --pkg-manager apt \
            --miniconda \
               conda_install="python=3.6 numpy pandas sklearn-lmer scipy rpy2=2.9.4 r-lme4 r-lmertest r-emmeans tzlocal seaborn" \
               create_env='mb-mm' \
               activate=true
}

# generate files
generate_docker > Dockerfile
generate_singularity > Singularity

# check if images should be build locally or not
if [ '$1' = 'local' ]; then
  if [ '$2' = 'docker' ]; then
    echo "docker image will be build locally"
    # build image using the saved files
    docker build -t mindboggle_mm:test .
  elif [ '$2' = 'singularity']; then
    echo "singularity image will be build locally"
    # build image using the saved files
    singularity build mindboggle_mm.simg Singularity
  elif [ '$2' = 'both' ]; then
    echo "docker and singularity images will be build locally"
    # build images using the saved files
    docker build -t mindboggle_mm:test .
    singularity build mindboggle_mm.simg Singularity
  elif [ -z "$2" ]; then
    echo "Please indicate which image should be build. You can choose from docker, singularity or both."
  fi
else
  echo "Image(s) won't be build locally."
fi
