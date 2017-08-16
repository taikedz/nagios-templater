# Nagios Tooling

Some tooling to make working with Nagios a little easier.

## Concepts

This is basic tooling for basic nagios usage. It makes use specifically of 5 of the objects in Nagios:

* Contacts
* Contact Groups
* Hosts
* Hostgroups
* Services

To this end

* Contacts reference Contact Groups
* Hosts reference Contact Groups
* Hosts and Services both reference Host Groups

Notably in this tooling, "Host Groups" are termed as "Service Hosts" to better reflect the association pattern.

## Workflow

1. Define Contact Group
2. Define Contact
3. Define Service Host
4. Define Service
5. Define Host

Example commands

	ngt set contactgroup -n NAME [-d DESCRIPTION] [-u NOTESURL]

	ngt set contact -n NAME [-c CONTACTGROUP] [-m EMAIL] [-t TEMPLATE|-T] [-d DESCRIPTION] [-u NOTESURL]

	ngt set servicehost -n NAME [-d DESCRIPTION] [-u NOTESURL]

	ngt set service -n NAME [-s SERVICEHOST] [-c COMMAND] [-t TEMPLATE|-T] [-d DESCRIPTION] [-u NOTESURL]

	ngt set host -n NAME [-c CONTACTGROUP] [-s SERVICEHOST] [-h HOSTNAME] [-t TEMPLATE|-T] [-d DESCRIPTION] [-u NOTESURL]

Each command prints the resulting file that is added or modified. The name is always required ; if object to be created does not exist yet, then only template, description and note URL are optional.

The `-t TEMPLATE`  option allows to base off of a template. The `-T` option defines the object as a template. `-t` and `-T` are mutually exclusive.

(Note to self: this should be implemented using the same comments system as described below)

(Note to self: the templates should be stored in a `/var/ngtools/ngtemplates/` folder)

(Note to self: generalize this ...?)

## Default templates

This tooling provides some generic objects out of the box:

* `ngt-contact`
* `ngt-nsc-host`
* `ngt-nrpe-host`
* `ngt-nsc-command`

Whilst you may not need these, they provide a solution to problems encountered in some situations. They are not active by default ; to activate one, for example:

	ngt genadd ngt-nsc-command

which adds a fixed `check_nt` command as `ngt_check_nt`, if the default command is broken.

Some will require parameters to configure them, you will be prompted interactively, or can supply them on the command line. To find out required configuration options, use

	ngt genhelp ngt-nsc-command

(Note to self: this should be implemented as a top of file comment, like

	## -p PASSWORD : the password to use when connecting
	## -n NAME : the name of the comand

	define command {
		command_name    %NAME%
		command_line    /usr/lib/nagios/plugins/check_nt -H '$HOSTADDRESS$' %PASSWORD% -p 12489 -v '$ARG1$' $ARG2$
	}

)
