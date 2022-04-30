from threading import local
import yaml
import os
import sys
import git

current_dir = os.path.dirname(__file__)
#dir_path = os.path.dirname(os.path.realpath(__file__))
mock_release_vars_file = os.path.join(current_dir, 'mock-release-vars.yaml')

def flatten_env_vars_array_to_dict(env_vars_array):
    env_var_map = {}
    for var in env_vars_array:
        env_var_map[var['key']] = var['value']
    return env_var_map

print("Note: Python 3.9 or above required for certain conventions in-use\n")

# TODO: get this from command line args:
service_to_run = 'terraform'

# Read vars that will simulate those normally injected at runtime by Release:
f = open(mock_release_vars_file)
release_vars_yaml = yaml.safe_load(f)
f.close()


# find path to env vars and read contents into dict:
f = open('.release.yaml')
release_yaml = yaml.safe_load(f)
f.close()
# app_template_path = release_yaml['application_template']
env_vars_path = release_yaml['environment_variables']
f = open(env_vars_path)
env_vars_yaml = yaml.safe_load(f)
f.close()

# First, merge user-provided defaults into our mock Release-provided vars:
default_vars = release_vars_yaml | flatten_env_vars_array_to_dict(env_vars_yaml['defaults'])

# Merges service_vars into default_vars (service_vars will overwrite if a key already in defaults):
services = env_vars_yaml['services']
if (service_to_run in services):
    service_vars = flatten_env_vars_array_to_dict(services[service_to_run])
else:
    service_vars = []
combined_vars = default_vars | service_vars 

# Apply mappings:
mappings = (env_vars_yaml['mapping'])
for key in mappings:
    print 
    mapped_key = mappings[key]
    if mapped_key in combined_vars:
        combined_vars[key] = combined_vars[mapped_key]
    else:
        raise SystemExit(f'[ERROR] {mapped_key} is referenced in mapping but not defined in environment_variables.yaml')

# Write vars to output file
# TODO: probably need something to handle secrets properly, maybe better logic for quoting strings?
local_vars_file = f'{current_dir}/local-vars-for-docker-run'
f = open(local_vars_file, 'w')
for key in combined_vars: 
    #env_var_string = key + "=\"" + str(combined_vars[key]) + "\"\n"
    env_var_string = key + "=" + str(combined_vars[key]) + "\n"
    f.write(env_var_string)

f.close()

with open(local_vars_file, 'r') as f:
    print(f.read())