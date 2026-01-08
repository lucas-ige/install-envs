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
#SBATCH --ntasks-per-node=6
#SBATCH --time=03:00:00

set -e

#-------------------------#
# User-defined parameters #
#-------------------------#

dir_env=/scratchu/$(whoami)/install-env

modules=(
    gcc/11.2.0
    openmpi/4.0.7
)

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

function fix_permissions {
    # Fix permissions in given directory.
    #
    # This function sets all the files and directories to read-only, and, for
    # each file, gives the same executable permissions to the group as it finds
    # for the owner. It also removes any permission that might be given to all
    # users. In short, it gives the following permissions:
    #
    # -> r-xr-x--- to directories.
    # -> r-xr-x--- to files that are already executable by the owner.
    # -> r--r----- to all the other files.
    #
    # Parameters
    # ----------
    # $1: directory
    #     Directory where permissions will be adjusted.
    #
    if [[ $# -ne 1 || ! -d $1 ]]; then
        echo "Error: give the path to an existing directory as only argument."
        exit 1
    fi
    dir_now=$(pwd)
    cd $1
    find -type f -perm -u=x -exec chmod 550 {} \;
    find -type f ! -perm 550 -exec chmod 440 {} \;
    find -type d -exec chmod 550 {} \;
    cd $dir_now
}

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
        echo "prepend-path PATH $dir_installed/bin" >> $dest
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
    chmod 440 $dest
}

#---------#
# Prepare #
#---------#

for m in ${modules[@]}; do
    module load $m
done

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

    version_zlib=${tag_zlib#v}
    dir_zlib=$dir_env/zlib-v$version_zlib

    if [[ ! -d $dir_zlib ]]; then

        # Install zlib
        cd $dir_repo/zlib
        ./install.bash \
            --destination $dir_zlib \
            --commit $tag_zlib
        fix_permissions $dir_zlib

        # Create module file for zlib
        cd $dir_repo
        create_module_file \
            --installed $dir_zlib \
            --whatis "The zlib library" \
            ${modules[@]/#/--prereq }

    fi

    for tag_hdf5 in ${tags_hdf5[*]}; do

        version_hdf5=${tag_hdf5#hdf5_}
        version_hdf5=${version_hdf5//_/.}
        dir_hdf5=$dir_env/hdf5-v${version_hdf5}_zlib-v$version_zlib

        if [[ ! -d $dir_hdf5 ]]; then

            # Install HDF5
            cd $dir_repo/hdf5
            ./install.bash \
                --destination $dir_hdf5 \
                --commit $tag_hdf5 \
                --zlib $dir_zlib
            fix_permissions $dir_hdf5

            # Create module file for HDF5
            cd $dir_repo
            create_module_file \
                --installed $dir_hdf5 \
                --whatis "The HDF5 library" \
                ${modules[@]/#/--prereq } \
                --prereq $dir_zlib.module

        fi

        # For convenience (and because some programs make this assumption
        # eg. the official WRF installation scripts), we install the NetCDF C
        # and FORTRAN libraries in the same directory
        for tag_netcdf_c in ${tags_netcdf_c[*]}; do
            for tag_netcdf_fortran in ${tags_netcdf_fortran[*]}; do

                version_netcdf_c=${tag_netcdf_c#v}
                version_netcdf_fortran=${tag_netcdf_fortran#v}
                dir_netcdf=$dir_env/netcdf-fortran-
                dir_netcdf+=v${version_netcdf_fortran}
                dir_netcdf+=_netcdf-c-v${version_netcdf_c}
                dir_netcdf+=_hdf5-v${version_hdf5}
                dir_netcdf+=_zlib-v${version_zlib}

                if [[ ! -d $dir_netcdf ]]; then

                    # Install netcdf-c
                    cd $dir_repo/netcdf-c
                    ./install.bash \
                        --destination $dir_netcdf \
                        --commit $tag_netcdf_c \
                        --zlib $dir_zlib \
                        --hdf5 $dir_hdf5

                    # Install netcdf-fortran
                    cd $dir_repo/netcdf-fortran
                    ./install.bash \
                        --destination $dir_netcdf \
                        --commit $tag_netcdf_fortran \
                        --netcdf-c $dir_netcdf

                    # Create module file for netcdf-*
                    cd $dir_repo
                    create_module_file \
                        --installed $dir_netcdf \
                        --whatis "The NetCDF C and FORTRAN libraries" \
                        ${modules[@]/#/--prereq } \
                        --prereq $dir_hdf5.module

                    fix_permissions $dir_netcdf

                fi

            done
        done

    done

done

chmod 550 $dir_env
chmod 550 $dir_env/..
