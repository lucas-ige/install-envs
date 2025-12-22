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
#SBATCH --time=03:00:00

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

tags_netcdf_fortran=(
    v4.6.2
)

#-------------#
# Function(s) #
#-------------#

function create_module_file {
    # Create module file for a library.
    #
    # Parameters
    # ----------
    # --installed (-i): path
    #     Path to the library installation directory for which we want to
    #     create the module.
    # --prereq (-p): path
    #     Path to a pre-required module. This option can be specified multiple
    #     times
    # --whatis (-w): text
    #     A short description of the library.
    #
    prereqs=()
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--installed)
                dir_installed=$2
                shift
                shift
                ;;
            -p|--prereq)
                prereqs+=($2)
                shift
                shift
                ;;
            -w|--whatis)
                whatis=$2
                shift
                shift
                ;;
            *)
                echo "Error: unknown command-line argument: $1"
                exit 1
                ;;
        esac
    done
    dest=$dir_installed.module
    sed -e "s/<whatis>/$whatis/g" \
        -e "s/<help>/$whatis/g" \
        template.module > $dest
    echo "" >> $dest
    for prereq in ${prereqs[*]}; do
        echo "prereq $prereq" >> $dest
    done
    echo "" >> $dest
    if [[ -d $dir_installed/lib ]]; then
        echo "prepend-path LD_LIBRARY_PATH $dir_installed/lib" >> $dest
    fi
    if [[ -d $dir_installed/bin ]]; then
        echo "prepend-path PATH $dir_installed/lib" >> $dest
    fi
    if [[ -d $dir_installed/lib/pkgconfig ]]; then
        echo "prepend-path PKG_CONFIG_PATH $dir_installed/lib/pkgconfig" >> $dest
    fi
    echo "prepend-path CMAKE_PREFIX_PATH $dir_installed" >> $dest
    name=$(basename $dir_installed)
    name=${name%%-v*}
    name=${name//-/_}
    name=${name^^}
    echo "setenv ${name}_ROOT $dir_installed" >> $dest
}

#---------#
# Prepare #
#---------#

dir_repo=$(pwd)
version_gcc=$(gcc --version | head -n 1 | awk '{print $NF}')
version_gfortran=$(gfortran --version | head -n 1 | awk '{print $NF}')
if [[ "$version_gcc" != "$version_gfortran" ]]; then
    echo "Error: GCC and GFORTRAN versions mismatch."
    exit 1
fi
dir_env+=/gcc-v$version_gcc
mkdir -p $dir_env
dir_env="$(cd "${dir_env}" && pwd -P)"

#-------------------------#
# Install the environment #
#-------------------------#

for tag_zlib in ${tags_zlib[*]}; do

    # Install zlib library
    version_zlib=${tag_zlib#v}
    dir_zlib=$dir_env/zlib-v$version_zlib
    if [[ ! -d $dir_zlib ]]; then
        cd $dir_repo/zlib
        ./install.bash \
            --destination $dir_zlib \
            --commit $tag_zlib
    fi

    # Create zlib module file
    cd $dir_repo
    create_module_file \
        --installed $dir_zlib \
        --whatis "The zlib library"

    for tag_hdf5 in ${tags_hdf5[*]}; do

        # Install HDF5 library
        version_hdf5=${tag_hdf5#hdf5_}
        version_hdf5=${version_hdf5//_/.}
        dir_hdf5=$dir_env/hdf5-v${version_hdf5}_zlib-v$version_zlib
        if [[ ! -d $dir_hdf5 ]]; then
            cd $dir_repo/hdf5
            ./install.bash \
                --destination $dir_hdf5 \
                --commit $tag_hdf5 \
                --zlib $dir_zlib
        fi

        # Create HDF5 module file
        cd $dir_repo
        create_module_file \
            --installed $dir_hdf5 \
            --whatis "The HDF5 library" \
            --prereq $dir_zlib.module

        for tag_netcdf_c in ${tags_netcdf_c[*]}; do

            # Install netcdf-c library
            version_netcdf_c=${tag_netcdf_c#v}
            dir_netcdf_c=$dir_env/netcdf-c-v${version_netcdf_c}
            dir_netcdf_c+=_hdf5-v${version_hdf5}_zlib-v${version_zlib}
            if [[ ! -d $dir_netcdf_c ]]; then
                cd $dir_repo/netcdf-c
                ./install.bash \
                    --destination $dir_netcdf_c \
                    --commit $tag_netcdf_c \
                    --zlib $dir_zlib \
                    --hdf5 $dir_hdf5
            fi

            # Create netcdf-c module file
            cd $dir_repo
            create_module_file \
                --installed $dir_netcdf_c \
                --whatis "The NetCDF C library" \
                --prereq $dir_zlib.module \
                --prereq $dir_hdf5.module

            for tag_netcdf_fortran in ${tags_netcdf_fortran[*]}; do

                # Install netcdf-fortran library
                version_netcdf_fortran=${tag_netcdf_fortran#v}
                dir_netcdf_fortran=$dir_env/netcdf-fortran-
                dir_netcdf_fortran+=v${version_netcdf_fortran}
                dir_netcdf_fortran+=_netcdf-c-v${version_netcdf_c}
                dir_netcdf_fortran+=_hdf5-v${version_hdf5}
                dir_netcdf_fortran+=_zlib-v${version_zlib}
                if [[ ! -d $dir_netcdf_fortran ]]; then
                    cd $dir_repo/netcdf-fortran
                    ./install.bash \
                        --destination $dir_netcdf_fortran \
                        --commit $tag_netcdf_fortran \
                        --netcdf-c $dir_netcdf_c
                fi

                # Create netcdf-fortran module file
                cd $dir_repo
                create_module_file \
                    --installed $dir_netcdf_fortran \
                    --whatis "The NetCDF FORTRAN library" \
                    --prereq $dir_zlib.module \
                    --prereq $dir_hdf5.module \
                    --prereq $dir_netcdf_c.module

            done

        done

    done

done
