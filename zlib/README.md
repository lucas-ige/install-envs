Use the script `install.bash` to compile and install the zlib library. It uses the following input arguments:

 - `--destination (-d)`: where the zlib library will be installed.

 - `--commit (-c)`: the version to compile. It can be any reference accepted by `git checkout`, including a branch
   name, a tag, or a commit hash.

For example:

```sh
./install.bash -d /home/myself/zlib -c v1.3.1
```

> [!IMPORTANT]
> This script must be executed from its directory.
