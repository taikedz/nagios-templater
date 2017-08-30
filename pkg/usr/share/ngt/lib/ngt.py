#!/usr/bin/python3

def fail(code, message):
    print(message)
    exit(n)

def populate_parameters(params):

    # eg params['NAME'] --> {'required' : <boolean> , 'flag' : <string>, 'value' : <string or None> }

    for parameter in params.keys():
        pobj = params[parameter]

        assign_user_value(pobj) # gets user value if any and stores in object

        if pobj['value'] == None and pobj['required']:
            fail(1, "Required parameter [ %s %s ] was not supplied." % (pobj['flag'], parameter) )

def perform_substitutions_in_file(targetfile, params):
    # iterate over file lines
    # for every line, check for a parameter requirement
    # process all requirements
    # line with [#!] if not all requirements met, remove it -------------- Can we not just make optional lines use default values instead ???
    # line with [#?] if not at least one requirement met, remove it

    for parameter in params.keys():
        substitute(parameter, params['value'])

def process(filename, cargs):

    params = params_declared(filename)
    populate_parameters(params)

    targetfile = copy_to_target(filename)
    perform_substitutions_in_file(targetfile, params)


def main(args):
    action = argv[1]
    filename = argv[2]

    if action == "args":
        dump_paramters(filename)

    elif action == "set":
        process(filename, args[2:])

    return 0

if __name__ == "__main__":
    from sys import argv
    exit( main(args) )
