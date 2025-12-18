This repository contains scripts to install computing libraries on different supercomputers.

Currently working:

 - The [zlib library](https://www.zlib.net/).
 - The [HDF5 library](https://www.hdfgroup.org/) (for versions < 2.0).

Work in progress:

 - The [NetCDF libraries](https://www.unidata.ucar.edu/software/netcdf/).

Philosophy on splitting user-defined options:

 - In `parameter.conf` files: things that should not change much from one install to the next.

 - Command-line arguments: things that will most likely be different at each install.
