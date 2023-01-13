# Ephemeral runners for GHA on macOS M1 using tart
**Requirements:**
* An arm64 mac running macOS 12 (Monterey) or later.
* A GitHub application that has permissions to create runners. No tutorial here right now folks, sorry.
* Python 3.7+

## Setup and installation
Run all this on the machine that will be hosting the VMs of course.

* Clone this repository
* Install tart (typically `brew install tart` for homebrew users)
* Download the latest arm64 macOS runner from https://github.com/actions/runner/releases/ and name the file `actions-runner.tar.gz`
* Follow the instructions inside `vm-build/README.md`
* Copy `config.toml.example` to `config.toml` and fill it out. `base_image_name` is the name of the image you built in the previous step.
* Create a virtualenv and install the dependencies into it: `python -m venv venv && venv/bin/pip install -r requirements.txt`
* Run it! `venv/bin/python server.py`

Making this into a launchd agent would be a good idea, but that is an exercise left to the reader at this time.

## Using it
Once you have a connected runner you can


### Future features if I feel like it
* Support PATs in addition to GitHub Apps (both classic and fine-grained)
* Support org-level runners instead of just repository runners (this is just a different endpoint)
* Write scripts to generate launchd scripts, install them, monitor resulting processes (much like GHA runners do)
* Make an entirely GHA compatible default image by exploiting their [existing packer scripts](https://github.com/actions/runner-images/blob/main/images/macos/templates). Images from Cirrus use user "admin", where GHA expects `/Users/runner`.

This project was built to fit the needs of [PyCA](https://github.com/pyca). Thanks to njs for the assistance with trio!
