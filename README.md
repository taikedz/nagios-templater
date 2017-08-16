# Nagios Tooling (NGT)

Some tooling to make working with Nagios a little easier.

## Concepts

This is basic tooling for basic nagios usage. It makes use specifically of 6 of the objects in Nagios:

* Contacts
* Contact Groups
* Hosts
* Hostgroups
* Services
* Service groups

To this end

* Contacts reference Contact Groups
* Hosts reference Contact Groups
* Hosts, Service groups, and Services all reference Hostgroups

Notably in NGT, "Hostgroups" are termed as "AppHosts" to better reflect the association pattern -- the grouping definition is, specifically, service-driven.

## Default templates

NGT provides some generic objects out of the box:

* `ngt-contact`
* `ngt-nsc-host`
* `ngt-nrpe-host`
* `ngt-nsc-command`

Whilst you may not need these, they provide a solution to problems encountered in some situations. They are not active by default ; to activate one, for example:

	ngt genadd ngt-nsc-command

which adds a fixed `check_nt` command as `ngt_check_nt`, if the default command is broken.

Some will require parameters to configure them, you will be prompted interactively, or can supply them on the command line. To find out required configuration options, use

	ngt genhelp ngt-nsc-command

## Meta-Templates

A Meta-Template is used to build objects, an even opbject templates themselves.

Meta-Template format looks like this:

	##! -n NAME : the name of the comand
	##? -p PASSWORD : the password to use when connecting

	define command {
		command_name    {{NAME}}
		command_line    /usr/lib/nagios/plugins/check_nt -H '$HOSTADDRESS$' {{PASSWORD}} -p 12489 -v '$ARG1$' $ARG2$
	}

Running the help prints the relevant arguments lines ; these are also used to parse the arguments and apply them in-template.

A `##!` marks a mandatory parameter ; a `##?` marks an optional parameter that will be substituted as blank if not provided.

## Workflow

1. Define Contact Group
2. Define Contact
3. Define Service Host
4. Define Service
5. Define Host

Example commands

	ngt set contactgroup -n NAME [-d DESCRIPTION] [-u NOTESURL]

	ngt set contact -n NAME -c CONTACTGROUP -m EMAIL {-t TEMPLATE|-T} [-d DESCRIPTION] [-u NOTESURL]

	ngt set servicehost -n NAME -d DESCRIPTION [-u NOTESURL]

	ngt set servicegroup -n NAME -a APPHOSTS -c COMMAND {-t TEMPLATE|-T} [-d DESCRIPTION] [-u NOTESURL]

	ngt set service -n NAME {-a APPHOSTS|-s SERVICEGROUP} -c COMMAND {-t TEMPLATE|-T} [-d DESCRIPTION] [-u NOTESURL]

	ngt set host -n NAME -c CONTACTGROUP -a APPHOSTS -h HOSTNAME {-t TEMPLATE|-T} [-d DESCRIPTION] [-u NOTESURL]

Each command prints the resulting file that is added. If the object already eixsts, it is overwritten.

The `-t TEMPLATE`  option allows to base off of a template. The `-T` option defines the object as a template. `-t` and `-T` are mutually exclusive, one of them must be provided.

All of these are based themselves on Meta-Templates stored in `/var/ngtools/ngtemplates/`

Other commands (where `OBJTYPE` is one of `contact`, `contactgroup`, `service`, `servicegroup`, `servicehost`, `host`)

	ngt rename OBJTYPE OBJNAME1 OBJNAME2

	ngt del OBJTYTPE OBJNAME

	ngt purge { OBJTYPE | all }

The `rename` operation renames an object from name 1 to name 2

The `del` operation removes the object

The `purge` operation removes all NGT objects of that type, or all NGT objects where `all` is specified.

## Nagios `/etc` structure

	/etc/nagios3/ngt-objects
		|
		+-- templates/
		|
		+-- contacts/
		|
		+-- services/
		|
		+-- hosts/

* Templates reside in `templates/`
* Contacts and Contact Groups reside in `contacts/`
* Services, Service gruops, and Service Hosts reside in `services/`
* Hosts reside in `hosts/`


