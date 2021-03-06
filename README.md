# Nagios Tooling (NGT)

Some tooling to make working with Nagios a little easier.

## Jinja2 Templates

HGT uses Jinja2 templates to build Nagios objects, as well as Nagios object templates themselves.

## Commands

Examples

	ngt add contactgroup -n NAME [-d DESCRIPTION] [-u NOTESURL]

	ngt add contact -n NAME -cg CONTACTGROUP -m EMAIL [-d DESCRIPTION] [-u NOTESURL]

	ngt add servicehost -n NAME -d DESCRIPTION [-u NOTESURL]

	ngt add app -n NAME -s SERVICEHOSTS -c COMMAND -cg CONTACTGROUP [-d DESCRIPTION] [-u NOTESURL]

	ngt add service -n NAME {-s SERVICEHOSTS|-a APP} -c COMMAND -cg CONTACTGROUP [-d DESCRIPTION] [-u NOTESURL]

	ngt add host -n NAME -c CONTACTGROUP -s SERVICEHOST -h HOSTNAME [-d DESCRIPTION] [-u NOTESURL]

Each command prints the resulting file that is added. If the object already exists, it is overwritten.

All of these are based themselves on Jinja2 templates stored in `/var/ngtools/ngtemplates/`

Other commands (where `OBJTYPE` is one of `contact`, `contactgroup`, `service`, `app`, `servicehost`, `host`)

	ngt rename OBJTYPE OBJNAME1 OBJNAME2

	ngt del OBJTYTPE OBJNAME

	ngt purge { OBJTYPE | all }

The `rename` operation renames an object from name 1 to name 2

The `del` operation removes the object

The `purge` operation removes all NGT objects of that type, or all NGT objects where `all` is specified.

## Nagios `/etc` structure

	/etc/nagios3/ngt-objects
		|
		+-- commands/
		|
		+-- templates/
		|
		+-- contacts/
		|
		+-- services/
		|
		+-- hosts/

* Command definitions reside in `commands/`
* Templates reside in `templates/`
* Contacts and Contact Groups reside in `contacts/`
* Services, Service gruops, and Service Hosts reside in `services/`
* Hosts reside in `hosts/`

## FAQ

### How do I associate a host with a service?

Nagios does not allow Hosts to specify directly what services they want. Instead, we tie them together around a Service Host

1. Associate the Service with a Service Host
	* Or, associate the Service with an App
	* Associate the App with a Service Host
2. Associate the Host with the Service Host

### How do I manage my nagios inventory with my orchestration inventory?

You should choose one inventory to form the basis of the other. In NGT's preference, I suggest that you use your orchestration tool to generate NGT lines as a bash script.

Such a bash script might look like this:

	ngt purge hosts
	ngt set host -n wiki -s http-servers -h wiki.example.com -d "Information docs"
	ngt set host -n jenkins -s tomcat-servers,build-nodes -h build.example.com -d "Build automation server" -u http://wiki.example.com/wiki/BuildServer
	ngt set host -n buildnode1 -s build-nodes -h b1.example.com
	ngt set host -n buildnode2 -s build-nodes -h b2.example.com

This would be backed by a separate Nagios configuration script such as

	ngt purge servicehosts
	ngt purge apps

	ngt set servicehost -n http-servers
	ngt set servicehost -n build-nodes
	ngt set servicehost -n tomcat-servers

	ngt set app -n webbuild -s build-nodes

	ngt set service -n tomcat -cg webadmins
	ngt set service -n http -s http-servers -a webbuild -cg webadmins
	ngt set service -n jnlp-agent -a webbuild -cg webadmins

