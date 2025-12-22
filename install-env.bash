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

#-------------------------#
# User-defined parameters #
#-------------------------#

dir_env=/scratchu/$(whoami)/install-env

versions_zlib=(
    1.2.13
    1.3.1
)

#-------------------------#
# Install the environment #
#-------------------------#

dir_repo=$(pwd)

for v in ${versions_zlib[*]}; do
    dir_zlib=$dir_env/zlib/v$v
    if [[ ! -d $dir_zlib ]]; then
        cd $dir_repo/zlib
        ./install.bash --destination $dir_zlib --commit v$v
    fi
done
