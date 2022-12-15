## General Info

The main goal of the project is to make easier to test various Wine version on
FreeBSD. At this moment it can be used in two ways:

1. As a simple download page with prebuild versions of Wine. This way is
   recommended for experienced users, as installation of a 32-bit version of
   Wine can be a bit tricky.

2. The tool to maintain various version of Wine installed in the same time in
   the system. It is the recommended way to use it.

You can also build your own version of the project. All files needed for it are
available in the repository.

## Wine versions

All available precompiled Wine versions are on [Releases](https://github.com/thindil/wine-freesbie/releases)
page. The releases are named in form [FreeBSD Version]-[architecture]. Thus,
13.1-amd64 means packages for FreeBSD 13.1 with amd64 architecture. There are 3
kinds of Wine packages available to use.

1. *wine-devel* or *wine-proton*: they are vanilla packages build in the same
   way as packages available in FreeBSD repository. As FreeBSD doesn't provide
   older versions of packages, they can be used to fast check without need to
   build them on your own.
2. *wine-staging*: this is *wine-devel* version with enabled *staging* patches.
   It may provide better or worse support for Windows programs than the vanilla
   packages.
3. *wine-patched*: *wine-staging* or *wine-proton* versions with added additional
   patches not available for vanilla packages. The kind of patches are depends
   on each package. Same as *wine-staging*, it may solve or cause some problems
   with running Windows programs on FreeBSD.

## Using the project as tool to maintain Wine

To use the project to maintain various versions of Wine installed in the
system, first you have to download the maintenance script [freesbie.sh](https://raw.githubusercontent.com/thindil/wine-freesbie/main/freesbie.sh).
It is recommended to put it somewhere in your `PATH` directory.

1. Download the script. ;) `fetch https://raw.githubusercontent.com/thindil/wine-freesbie/main/freesbie.sh`
   and put it somewhere in your system. This guide assumes that you put the
   script in your `PATH` directory.
2. The next step is to initialize the project. As a normal user execute the
   script with *init* argument: `freesbie.sh init`. It will create all needed
   directories and download all needed packages, 64 and 32-bit.
3. Find the version of Wine which you want to install on [Releases](https://github.com/thindil/wine-freesbie/releases)
   page. You can install it by running the maintenance script wit arguments
   *install [wine version]*. For example: `freesbie.sh install
   wine-patched-7.4.1`. It will download both versions of Wine, unpack them to
   proper locations and modify to work from the project's directory.

If you want to remove an installed version of Wine you can do this by running
the script with arguments *remove [wine version]*. For example: `freesbie.sh
remove wine-patched-7.4.1`.

To keep 32-bit versions of packages updated, run the maintenance script wit
*update* argument: `freesbie.sh update`.

**IMPORTANT:** When executing a Windows program with any Wine-freesbie version
of Wine, use for it `wine64` script not `wine`. Even the 32-bit version of
program. The proper way to run a program:

`~/freesbie/amd64/usr/local/wine-patched-7.4.1/bin/wine64 myprogram.exe`

The same is true for Wine utilities like `winecfg`, etc.

## Limitations

At this moment the maintenance script is very simple. Also, the changes to run
Wine from non-standard location are basic. If you are interested, feel free to
send pull request with changes, but I suggest starting a [discussion](https://github.com/thindil/wine-freesbie/discussions)
about what you want to change.

## FAQ

##### How I can request existing in FreeBSD ports tree version of Wine to add to the project?

Use the project [issues](https://github.com/thindil/wine-freesbie/issues/new?assignees=&labels=&template=version-request.md&title=%5BNew+version%5D).
Please read carefully information inside, because if the desired version of
Wine doesn't exist in FreeBSD ports tree, it will be rejected.

##### How I can request a new version of Wine or some custom patches to it or even an existing version?

You can't. ;) The only way to have a new version or custom patches is to create
it by yourself and use [Pull requests](https://github.com/thindil/wine-freesbie/pulls)
feature. Again, please read carefully information in the request template. Wine
versions without proof that they can be build will not be accepted.

##### My program doesn't work with the selected Wine version

Try to use another version of Wine. Don't report a problem if something doesn't
work. It is beyond of scope of the project. The exception to the rule are
bugs or issues created by the project, like the one mentioned in **IMPORTANT**
paragraph above.

##### I have question not mentioned here, or I want to discuss something related to the project.

Please use [discussions](https://github.com/thindil/wine-freesbie/discussions)
feature for it. Just please be civilized, at least at the level of ancients
civilizations. :)

---
That's all for now, I have probably forgotten about something important ;)

Bartek thindil Jasicki
