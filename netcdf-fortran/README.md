Use the script `install.bash` to compile and install the netcdf-fortran library. It uses the following input arguments:

 - `--commit (-c)`: the version to compile. It can be any reference accepted by `git checkout`, including a branch
   name, a tag, or a commit hash.

 - `--destination (-d)`: where the netcdf-fortran library will be installed.

 - `--netcdf-c (-n)`: where the netcdf-c library was installed.

For example:

```sh
./install.bash \
    -c v4.6.2 \
    -d /home/myself/netcdf-fortran \
    -n /home/myself/netcdf-c
```

> [!IMPORTANT]
> This script must be executed from its directory.
