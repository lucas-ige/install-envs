Use the script `install.bash` to compile and install the HDF5 library. It uses the following input arguments:

 - `--commit (-c)`: the version to compile. It can be any reference accepted by `git checkout`, including a branch
   name, a tag, or a commit hash.

 - `--destination (-d)`: where HDF5 will be installed.

 - `--zlib (-z)`: where the zlib library was installed.

For example:

```sh
./install.bash -c hdf5_1.14.6 -d /home/myself/hdf5 -z /home/myself/zlib
```

> [!IMPORTANT]
> This script must be executed from its directory.

> [!NOTE]
> This script only supports versions of HFD5 prior to 2.0. Starting at version 2.0, HDF5 only supports cmake as a
> compilation method, and I have not implemented this yet.
