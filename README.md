## What for?
This Docker container provides an environment ready for contributing to Qt, based on Ubuntu 16.04. Desktop is accessible from a VNC client (port 5901) or with a web browser (http://localhost:6901).

It can be used to:
* Contribute to the Qt framework development, as it provides the standard tools for it
* Develop against the latest version of Qt available, or a specific branch of tag, otherwise not available from binary releases

It contains:
* The latest Qt sources, compiled and ready for hacking or development
* Qt online installer in the Home (/headless) folder, to install Qt Creator or different Qt versions
* Essential tools: git, gdb, valgrind and qtrepotools
* The recommended Git configuration for Qt

Websites:
* Github: https://github.com/Pixep/qt-contribution-docker
* Docker: https://hub.docker.com/r/aleravat/qt-contribution-env/

## Usage
Run this container with `--privileged` or `--security-opt seccomp:unconfined` to allow GDB to work correctly.

Run a new container, and expose ports 5901 (VNC) and 6901 (noVNC):
```
docker run -d -p 5901:5901 -p 6901:6901 --privileged aleravat/qt-contribution-env:essential-latest
```

You can then use a VNC client to connect on `127.0.0.1:5901`, or browse to `http://127.0.0.1:6901`. The default password inherited from the base image is `vncpassword`.

## Custom build
The command below will build the image from scratch. We used `tee` to redirects the output to standard output and a build log.
```
docker build -t qt-contribution-env . | tee build.log
```

Given the size of Qt sources, make sure Docker has enough memory and disk space available. The final image takes about 13GB after cloning and building the full repository.

### Options
Build arguments are passed to Docker with "--build-arg OPTIONNAME=value", and can be used multiple times. Below, a list of the arguments available:

* `BRANCH` (defaults to `dev`)
  - Branch used from Qt git repository (https://github.com/qt/qt5/branches)
* `CODEREVIEW_USER`
  - Will set your gerrit `--codereview-username` for `init-repository`
* `CONFIGURE_FLAGS`
  - Additional flags to be passed to the `configure` step
* `MODULE_SUBSET` (defaults to `default,-qtwebkit,-qtwebkit-examples,-qtwebengine,-qtlocation,-qt3d,-qtwebengine`)
  - Argument passed to the `init-repository --module-subset=`, used to set the build profile (`default`, `essential`) and the modules to include or exclude.
* `MAKE_FLAGS` (defaults to `-j6`)
  - Flags passed directly to `make` when building Qt

Command line example:
```
docker build -t qt-contribution-env --build-arg MAKE_FLAGS=-j9 --build-arg MODULE_SUBSET=essential . | tee build.log
```

### init-repository submodules
Extracted from the documentation of `init-repository`:
```
--module-subset=<module1>,<module2>...
        Only initialize the specified subset of modules given as the
        argument. Specified modules must already exist in .gitmodules. The
        string "all" results in cloning all known modules. The strings
        "essential", "addon", "preview", "deprecated", "obsolete", and
        "ignore" refer to classes of modules; "default" maps to
        "essential,addon,preview,deprecated", which corresponds with the
        set of maintained modules and is also the default set. Module
        names may be prefixed with a dash to exclude them from a bigger
        set, e.g. "all,-ignore".
```
