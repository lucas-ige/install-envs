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
    hdf5_1.14.6
)

tags_netcdf_c=(
    v4.9.3
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

        for tag_netcdf_c in ${tags_netcdf_c[*]}; do
            version_netcdf_c=${tag_netcdf_c#v}
            dir_netcdf_c=$dir_env/netcdf-c/v${version_netcdf_c}
            dir_netcdf_c+=_hdf5-v${version_hdf5}_zlib-v${version_zlib}
            if [[ ! -d $dir_netcdf_c ]]; then
                cd $dir_repo/netcdf-c
                ./install.bash \
                    --destination $dir_netcdf_c \
                    --commit $tag_netcdf_c \
                    --zlib $dir_zlib \
                    --hdf5 $dir_hdf5
            fi
        done

    done

done
