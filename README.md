# MagiCd, makes cd become magic!

MagiCd is a set of bash scripts used to enhance the `cd` shell command. The purpose is to identify special directories and execute specific actions when entering or leaving them.

# Language/langue

Because French is my native language, finding all documents and messages in French is not an option. Other translations are welcome.

Anyway, because English is the language of programming, the code, including variable names and comments, are in English.

:fr: Une version française de ce document se trouve [ici](doc/fr/README.md).

# Licence

Copyright © 2016 Stéphane Veyret stephane_DOT_veyret_AT_neptura_DOT_org

MagiCd is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

MagiCd is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with MagiCd.  If not, see <http://www.gnu.org/licenses/>.

# Install

Compilation and installation should be as simple as:

    make && make install

Note that `make install` also support `DESTDIR` variable to install elsewhere than in system root directory.

# Usage

Automatic install of MagiCd creates aliases on `cd` and `clean` shell commands. When you enter in a special directory with the `cd` command, matching actions are executed. The `clean` command can be used in some cases to clean up a directory. This command is expecting the same arguments than `cd`.

In order to identify a special directory, you must add a file named `.magicd-`_category_, where _category_ identify the directory type. Different existing categories depend on scripts added to parameter directories. The added file may contain parameters. Usable parameters depend on category.

It is still possible to use command `\cd` in order to enter the directory without executing magic actions.

# Delivered categories

For the moment, there is only one standard delivered category.

## Docker

A `docker` directory contains a file named `.magicd-docker`. It is automatically bind to the `/root` directory of a Docker container.

### Entering

If there is no container which name is the name of the directory, a new one is created. If this container already exists, it is started. Instead of entering in the directory, we enter in the Docker container.

### Leaving

Directory exit is automatic when exiting the Docker container. Leaving does not start any action.

### Cleaning

Directory cleaning delete the container, and also images and volumes which are not used anymore.

### Parameters

Following options can be added in the `.magicd-docker` file:

* IMAGE=_docker image_, with the Docker image to be used, defaults to `gentoo/stage3-amd64`.
* OPTIONS=_options_, with options to be used, defaults to `--volumes-from portage`.
* CMD=_startup command_, with command to be executed at container startup, defaults to `/bin/bash`.

# Category definition

Directory categories will be searched in:

* the sub-directory `magicd.d` of the directory where is installed the main script of MagiCd, usually reserved for categories which are delivered with the application.
* the sub-directory `magicd.d` of the configuration directory, identified by the `$MAGICD_CONF` environment variable which, by default, equals `/etc`, used for categories which are global to the computer.
* the sub-directory `.magicd.d` of the user directory `$HOME`, for private categories of the user.

Those 3 directories are given by ascending priority order, the user directory overrides the 2 others, and the categories delivered with the application have the lowest priority.

# Write a category file

A category file must be found in one of the category definition directory and have the same name as the category. It can have 3 functions:

* `magicd_enter` contains actions to be executed when entering the directory.
* `magicd_leave` contains actions to be executed when leaving the directory.
* `magicd_clean` contains actions to be executed to clean the directory.

Commands `cd` and `clean` being potentially aliased to MagiCd, they must not be used directly in category scripts to prevent infinite loops. If a directory change is needed, the command `command cd`, which does not care of the alias, can be used.

Category file is sources by MagiCd. Therefore, it does not need to have execution rights, but it requires reading rights. On another hand, in order not to “pollute” environment, functions are executed in a sub-shell. Actions will not have an impact on the current environment.

If curent environment modification is needed (adding environment variables, curent directory change, etc.), instruction must be written to file descriptor #3. Everything written to this descriptor will end in a temporary file which will be sourced by MagiCd.

Sample 1 - Curent directory change:

    magicd_leave() {
        echo 'command cd ..' >&3
    }

Sample 2 - Environment variable addition:

    magicd_enter() {
        cat <<EOF >&3
    export NEW_HOME=\${PWD}
    export MY_VAR_SET="true"
		EOF
    }
