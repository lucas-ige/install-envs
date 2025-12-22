#!/bin/bash
#
# Copyright (c) 2025-now Institut des Géosciences de l'Environnement (UMR 5001).
#
# License: BSD 3-Clause "New" or "Revised" License (BSD-3-Clause).
#
# This script installs a full environment.
#
# This script should be run from its directory.
#

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=01:00:00

set -e

#-------------------------#
# User-defined parameters #
#-------------------------#

dir_env=/scratchu/$(whoami)/install-env

tags_zlib=(
    v1.3.1
)

tags_hdf5=(
    hdf5_1_10_11
    hdf5_1.14.6
)

#-------------------------#
# Install the environment #
#-------------------------#

dir_repo=$(pwd)

for tag_zlib in ${tags_zlib[*]}; do

    version_zlib=${tag_zlib#v}
    dir_zlib=$dir_env/zlib/v$version_zlib
    if [[ ! -d $dir_zlib ]]; then
        cd $dir_repo/zlib
        ./install.bash \
            --destination $dir_zlib \
            --commit $tag_zlib
    fi

    for tag_hdf5 in ${tags_hdf5[*]}; do
        version_hdf5=${tag_hdf5#hdf5_}
        version_hdf5=${version_hdf5//_/.}
        dir_hdf5=$dir_env/hdf5/v${version_hdf5}_zlib-v$version_zlib
        if [[ ! -d $dir_hdf5 ]]; then
            cd $dir_repo/hdf5
            ./install.bash \
                --destination $dir_hdf5 \
                --commit $tag_hdf5 \
                --zlib $dir_zlib
        fi
    done

done
