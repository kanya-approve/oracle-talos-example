import json
import subprocess

cmd = ["terraform", "state", "pull"]
output = subprocess.run(cmd, check=True, stdout=subprocess.PIPE).stdout
state = json.loads(output)

resources = state.pop("resources")

machine_configuration = {"controlplane": "", "worker": ""}

talosconfig = ""

for resource in resources:
    if resource["type"] == "talos_client_configuration":
        talosconfig = resource["instances"][0]["attributes"]["talos_config"]
    elif resource["type"] == "talos_machine_configuration":
        machine_configuration[resource["name"]] = resource["instances"][0][
            "attributes"
        ]["machine_configuration"]

with open("controlplane.yaml", "w") as f:
    f.write(machine_configuration["controlplane"])

with open("worker.yaml", "w") as f:
    f.write(machine_configuration["worker"])

with open("talosconfig", "w") as f:
    f.write(talosconfig)
