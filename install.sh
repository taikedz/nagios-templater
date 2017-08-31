
add_templates() {
	mkdir -p "$NGT_resources"
	cp "pkg/$NGT_resources/*" "$NGT_resources/"
}

add_progs() {
	# Args: array of progs corresponding to py files
	# eg ngt --> ngt.py
	
	mkdir -p "$NGT_lib"

	cp "pkg/$NGT_lib/*" "$NGT_lib/"

	for prog in "$@"; do
		local pylib="$NGT_lib/$prog.py"
		if [[ -f "$pylib" ]]; then
			ln -s "$pylib" "/usr/bin/$prog"
		fi
	done
}

faile() {
	echo "$*" >&2
	exit 1
}

ensure_line() {
	local file="$1"; shift
	local token="$1"; shift

	local semi=';'
	if [[ "$*" =~ $semi ]]; then
		faile "Invalid target line"
	fi

	sed -r 's;^(.*$token.*)$;$*;' -i "$file"
}

fix_files() {
	ensure_line /etc/nagios-plugins/config/nt.cfg 'check_nt ' "        command_line    /usr/lib/nagios/plugins/check_nt -H '\$HOSTADDRESS\$' -p 12489 -v '\$ARG1\$' \$ARG2\$"
}

install_nagios() {
	apt update && apt install nagios3 mailutils nagios-nrpe-plugin -y

	mkdir -p "$NGT_objects"
	mkdir /etc/ngt
	echo "objects-location = $NGT_objects" > /etc/ngt/main.conf

	echo "cfg_dir = /etc/nagios3/objects" >> /etc/nagios3/nagios.cfg

	fix_files
}

main() {
	[[ "$UID" = 0 ]] || {
		echo "You must be root to run this script"
		exit 1
	}

	cd "$(dirname "$0")"

	autojinja/install.sh

	# Base nagios install

	install_nagios

	# Out tools

	NGT_resources=/usr/share/ngt/resources
	NGT_lib=/usr/share/ngt/lib

	NGT_objects=/etc/nagios3/objects/ngt

	add_templates
	add_progs ngt
}

main "$@"
