# Helm Linux Packages

Debian supported so far.

## Usage

### Building the packages

Install the tools: [FPM](https://fpm.readthedocs.io/en/latest/installing.html), `curl`, `tar`

Set an environment variable for the Helm version for which you wish to build packages. Then build it.

```
export HELM_VERSION=3.2.0
./build-deb.sh
```

Additionally you can set the `DEB_REVISION` variable to 2 or more (it defaults to 1) to indicate a revision with changes to packaging but not to the binaries. Let this reset to 1 for each new Helm version.

### Testing the package

Test the package in a Docker container. This assumes `amd64` architecture.

```
export DEB_PACKAGE=helm  # or helm2
export DEB_VERSION=3.2.1-1
./test-deb.sh
```

Helm 3 exit code should be 0; Helm 2 exit code should be 1 because it hasn't been configured with a K8S cluster.

### Pushing to the repo

This assumes you're uploading to a [Debian repository from Balto](https://www.getbalto.com/debian.html). 

Set a few environment variables, then push it.

```
export DEB_VERSION=3.2.0-1
export REPO_USER=your-username
export REPO_PW=your-password
./push.sh
```

## Copyright

Packaging code is offered under the MIT license, copyright 2020 Matthew Fox.

Copyright for Helm binaries remains with the original owners.

