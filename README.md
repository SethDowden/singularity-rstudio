# Singularity RStudio Server

[![Build Status](https://travis-ci.org/nickjer/singularity-rstudio.svg?branch=master)](https://travis-ci.org/nickjer/singularity-rstudio)
[![Singularity Hub](https://www.singularity-hub.org/static/img/hosted-singularity--hub-%23e32929.svg)](https://singularity-hub.org/collections/463)
[![GitHub License](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)

Singularity image for [RStudio Server]. It was built on top of the base
Singularity image [nickjer/singularity-r].

This is still a work in progress.

## Build

You can build a local Singularity image named `singularity-rstudio.simg` with:

```sh
sudo singularity build singularity-rstudio.simg Singularity
```

## Deploy

Instead of building it yourself you can download the pre-built image from
[Singularity Hub](https://www.singularity-hub.org) with:

```sh
singularity pull --name singularity-rstudio.simg shub://nickjer/singularity-rstudio
```

## Run

### RStudio Server

The `rserver` command is launched using the default run command:

```sh
singularity run singularity-rstudio.simg
```

or as an explicit app:

```sh
singularity run --app rserver singularity-rstudio.simg
```

Example:

```console
$ singularity run --app rserver singularity-rstudio.simg --help
command-line options:

verify:
  --verify-installation arg (=0)        verify the current installation

server:
  --server-working-dir arg (=/)         program working directory
  --server-user arg (=rstudio-server)   program user
  --server-daemonize arg (=0)           run program as daemon
  --server-app-armor-enabled arg (=1)   is app armor enabled for this session
  --server-set-umask arg (=1)           set the umask to 022 on startup

...
```

#### Simple Password Authentication

To secure the RStudio Server you will need to:

1. Launch the container with the environment variable `RSTUDIO_PASSWORD` set to
   a password of your choosing.
2. Launch the `rserver` command with the PAM helper script `rstudio_auth`.

An example is given as:

```sh
RSTUDIO_PASSWORD="password" singularity run singularity-rstudio.simg \
  --auth-none 0 \
  --auth-pam-helper rstudio_auth
```

Now when you attempt to access the RStudio Server you will be presented with a
log in form. You can log in with your current user name and password you set in
`RSTUDIO_PASSWORD`.

#### LDAP Authentication

Another option is using an LDAP (or Active Directory) server for
authentication. Configuration of the LDAP authentication script `ldap_auth` is
handled through the following environment variables:

- `LDAP_HOST` - the host name of the LDAP server
- `LDAP_USER_DN` - the formatted string (where `%s` is replaced with the
  username supplied during log in) of the bind DN used for LDAP authentication
- `LDAP_CERT_FILE` - the file containing the CA certificates used by
  the LDAP server (default: use system CA certificates)

An example for an LDAP server with signed SSL certificate from a trusted CA:

```sh
export LDAP_HOST=ldap.example.com
export LDAP_USER_DN='cn=%s,dc=example,dc=com'
singularity run singularity-rstudio.simg \
  --auth-none 0 \
  --auth-pam-helper-path ldap_auth
```

An example for an LDAP server with a self-signed SSL certificate:

```sh
export LDAP_HOST=ldap.example.com
export LDAP_USER_DN='cn=%s,dc=example,dc=com'
export LDAP_CERT_FILE=/ca-certs.pem
singularity run \
  --bind /path/to/ca-certs.pem:/ca-certs.pem \
  singularity-rstudio.simg \
    --auth-none 0 \
    --auth-pam-helper-path ldap_auth
```

Note that we had to bind mount the CA certificates file from the host machine
into the container and specify the container's path in `LDAP_CERT_FILE` (not
the host's path).

### R and Rscript

See [nickjer/singularity-r] for more information on how to run `R` and
`Rscript` from within this Singularity image.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/nickjer/singularity-rstudio.

## License

The code is available as open source under the terms of the [MIT License].


[RStudio Server]: https://www.rstudio.com/products/rstudio/
[nickjer/singularity-r]: https://github.com/nickjer/singularity-r
[MIT License]: http://opensource.org/licenses/MIT


# RStudio Server + Singularity Module

This is an example [Lmod] module that sets up the environment necessary to
launch RStudio Server. It assumes a Singularity module already exists or that
it is installed on the machine.

*[Lmod] modules are typically used at most high-performance computing (HPC)
centers.*

## Setup

1. Modify the `modulefiles/x.y.z.lua` to your specification.
2. Download the corresponding Singularity image under
   `x.y.z/singularity-rstudio.simg`:

   ```console
   $ mkdir x.y.z
   $ cd x.y.z
   $ singularity pull --name singularity-rstudio.simg shub://nickjer/singularity-rstudio:x.y.z
   $ cd ..
   ```

The downloaded Singularity image [nickjer/singularity-rstudio] is entirely
optional. You are welcome to create and maintain your own images using the
above image as an example.

[nickjer/singularity-rstudio]: https://www.singularity-hub.org/collections/463

## Install Libraries

Users may request that you install R packages. I am not entirely sure if
installed packages work across major (`x`) or minor (`x.y`) version numbers. So
to err on the side of caution I treat packages separate within minor versions
of R (feel free to inform me otherwise).

1. Create a library for the corresponding R minor version if one doesn't
   already exist:

   ```console
   $ mkdir library-x.y
   ```
2. Confirm you have permissions to write to this directory.
3. Confirm the corresponding module files `modulesfiles/x.y.z.lua` point to
   this library.
4. Load any one of the corresponding module files and launch R:

   ```console
   $ module load rstudio_singularity/x.y.z
   $ R
   ```
5. Install requested packages:

   ```R
   install.packages("my_package", lib="/library")
   ```

   and be sure it is writing to the path `/library`.

### Locally Install Libraries

Although it should be noted that users can install their own R packages under
the `R_LIBS_USER` directory specified in the module file.

1. Load any one of the corresponding module files and launch R:

   ```console
   $ module load rstudio_singularity/x.y.z
   $ R
   ```
2. Install requested packages:

   ```R
   install.packages("my_package")
   ```

[Lmod]: https://www.tacc.utexas.edu/research-development/tacc-projects/lmod
