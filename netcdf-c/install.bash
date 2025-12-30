#!/bin/bash
#
# Copyright (c) 2025-now Institut des Géosciences de l'Environnement (UMR 5001).
#
# License: BSD 3-Clause "New" or "Revised" License (BSD-3-Clause).
#
# This script installs the netcdf-c library.
#
# This script should be run from its directory.
#

set -e

source ../parameters.conf
source parameters.conf

while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--commit)
            commit=$2
            shift
            shift
            ;;
        -d|--destination)
            dir_dest=$2
            shift
            shift
            ;;
        -z|--zlib)
            dir_zlib=$2
            shift
            shift
            ;;
        -h|--hdf5)
            dir_hdf5=$2
            shift
            shift
            ;;
        *)
            echo "Error: unknown command-line argument: $1"
            exit 1
            ;;
    esac
done
commit=${commit:-${default_branch}}

if [[ -z ${dir_dest} ]]; then
    echo "Error: please specify destination directory"
    exit 1
fi
mkdir -p ${dir_dest}
dir_dest="$(cd "${dir_dest}" && pwd -P)"
echo "Will install in ${dir_dest}"

if [[ -z ${dir_zlib} ]]; then
    echo "Error: please specify zlib directory"
    exit 1
fi
dir_zlib="$(cd "${dir_zlib}" && pwd -P)"

if [[ -z ${dir_hdf5} ]]; then
    echo "Error: please specify HDF5 directory"
    exit 1
fi
dir_hdf5="$(cd "${dir_hdf5}" && pwd -P)"

dir_work=./work_netcdf-c
if [[ -d ${dir_work} || -f ${dir_work} ]]; then
    echo "Error: work directory already exists (as file or directory)"
    exit 1
fi

echo "Cloning from repository: ${url_repo}"
git clone ${url_repo} ${dir_work}

echo "Checking out commit/branch/tag ${commit} from repository"
cd ${dir_work}
git checkout ${commit}

echo "Configuring, compiling, and installing"
export LD_LIBRARY_PATH="${dir_zlib}/lib:${dir_hdf5}/lib:$LD_LIBRARY_PATH"
CPPFLAGS="-I${dir_hdf5}/include -I${dir_zlib}/include" \
LDFLAGS="-L${dir_hdf5}/lib -L${dir_zlib}/lib" \
./configure --prefix=${dir_dest} ${configure_options}
make check
make install

echo "Cleaning up"
cd ..
rm -rf ${dir_work}

echo "netcdf-c installed successfully"
