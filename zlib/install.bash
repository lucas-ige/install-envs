#!/bin/bash
#
# Copyright (c) 2025-now Institut des Géosciences de l'Environnement (UMR 5001).
#
# License: BSD 3-Clause "New" or "Revised" License (BSD-3-Clause).
#
# This script installs the zlib library.
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
        *)
            echo "Error: unknown command-line argument: $1"
            exit 1
            ;;
    esac
done
commit=${commit:-develop}

if [[ -z ${dir_dest} ]]; then
    echo "Error: please specify destination directory"
    exit 1
fi

dir_work=./work_zlib
if [[ -d ${dir_work} || -f ${dir_work} ]]; then
    echo "Error: work directory already exists (as file or directory)"
    exit 1
fi

echo "Cloning from repository: ${url_repo}"
git clone ${url_repo} ${dir_work}

echo "Checking out commit/branch/tag ${commit} from repository"
cd ${dir_work}
git checkout ${commit}
