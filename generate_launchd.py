import os
from string import Template

BASE_DIR = os.path.dirname(__file__)

with open(os.path.join(BASE_DIR, "files", "launchd.template"), "r") as f:
    template = Template(f.read())

label = "tart-gha-ephemeral-runner"

output = template.substitute(
    label=label,
    python=f"{BASE_DIR}/venv/bin/python",
    server=f"{BASE_DIR}/server.py",
    user=os.environ.get("USER"),
    working_directory=BASE_DIR,
    home=os.environ.get("HOME"),
)
write_path = os.path.join(BASE_DIR, label + ".plist")
with open(write_path, "w") as f:
    f.write(output)

print(f"Wrote launchd file to {write_path}")
os.makedirs(
    os.path.join(os.environ.get("HOME"), "Library", "Logs", label), exist_ok=True
)
