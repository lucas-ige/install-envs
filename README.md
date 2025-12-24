This repository contains scripts to install computing libraries on different supercomputers.

# Intall an individual library

 1. Navigate to the directory corresponding to the library (eg. `./netcdf-c`).
 2. Read the `README.md` file.
 3. Optionally, modify parameters in `parameters.conf`.
 4. Use the script `install.bash` to install the library.

# Install a complete environment

 1. Open the script `install.bash` located at the root of this repository.
 2. Modify:
    - The directory where the environment will be installed (variable `dir_env`).
    - The versions of the libraries you want to install (these must be valid git tags). You can can specifiy more than
      one version for each library, in which case the script will install all the versions.
 3. Use the script `install.bash` to install the environment.

# Philosophy on splitting user-defined options:

 - In `parameter.conf` files: things that should not change much from one install to the next.

 - Command-line arguments: things that will most likely be different at each install.
