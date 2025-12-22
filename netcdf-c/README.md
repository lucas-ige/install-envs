Use the script `install.bash` to compile and install the netcdf-c library. It uses the following input arguments:

 - `--commit (-c)`: the version to compile. It can be any reference accepted by `git checkout`, including a branch
   name, a tag, or a commit hash.

 - `--destination (-d)`: where the netcdf-c library will be installed.

 - `--zlib (-z)`: where the zlib library was installed.

 - `--hdf5 (-h)`: where the HDF5 library was installed.

For example:

```sh
./install.bash \
    -c v4.9.3 \
    -d /home/myself/netcdf-c \
    -z /home/myself/zlib \
    -h /home/myself/hdf5
```

> [!IMPORTANT]
> This script must be executed from its directory.
