import json
from jinja2 import Environment, FileSystemLoader
import os
import argparse
import stat
import errno

TEMPLATE_DIR = "./templates/"
GENERATED_DIR = "./generated/"
CONFIG_FILE = "./config.json"

def prebuild():
    # prepare jinja env
    env = Environment(loader=FileSystemLoader('./'))

    # prepare user defined configs
    with open(CONFIG_FILE, 'r') as fp:
        config = json.load(fp)

    # generate directories
    if not os.path.exists(GENERATED_DIR):
        os.makedirs(GENERATED_DIR)

    os.chdir(TEMPLATE_DIR)
    for dp, _, _  in os.walk('./'):
        if not os.path.exists(os.path.join('../', GENERATED_DIR, dp)):
            os.makedirs(os.path.join('../', GENERATED_DIR, dp))

    # render all templates
    templates = [os.path.join(dp, f) for dp, dn, filenames in os.walk('./') for f in filenames]
    os.chdir('../')

    for template in templates:
        generated_filename = GENERATED_DIR + template.rsplit(".template")[0]
        with open(generated_filename, 'w') as fp:
            if template.endswith('.template'):
                fp.write(env.get_template(TEMPLATE_DIR + template).render(**config))
            else:
                with open(TEMPLATE_DIR + template, 'r') as rofp:
                    fp.write(rofp.read())

    scripts = ['build-all.sh', 'build-conf.sh', 'deploy.sh', 'provision.sh']
    for script in scripts:
        try:
            os.symlink(GENERATED_DIR + 'scripts/' + script, script)
        except OSError, e:
            if e.errno == errno.EEXIST:
                os.remove(script)
                os.symlink(GENERATED_DIR + 'scripts/' + script, script)

        st = os.stat(script)
        os.chmod(script, st.st_mode | stat.S_IEXEC)

if __name__ == '__main__':
    prebuild()
