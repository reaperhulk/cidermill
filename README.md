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

If you don't want to manually invoke, see the next section.

## Installing via launchd

* Run `venv/bin/python generate_launchd.py` and then copy the resulting file into `~/Library/LaunchAgents` and run `launchctl load ~/Library/LaunchAgents/tart-gha-ephemeral-runner.plist`. This will immediately launch the runner (and will auto-launch it at boot).

There is also an optional file `.path`, which, if it exists, will be loaded as the `PATH` variable for the running Python process. This is useful in contexts where you don't have a login shell (e.g. a launchd agent). You can create this from a shell where you have the right `PATH` with `echo $PATH > .path`.

**Note:** If you're running on Ventura you'll see a "Background Items Added" message appear when you move the plist into `~/Library/LaunchAgents`. Depending on whether the Python you're using is code signed you might see an odd message like "Software from "Ned Deily"". Good times.

You may also have to reboot to make the agent actually run. `launchd` is a mysterious beast.

## Using it
Once you have a connected runner you can invoke it from a workflow with the correct runs-on key:

>    runs-on: [self-hosted, macos, ARM64, tart]

The GitHub Actions runner will automatically apply the first 3 tags, but any other tag (including `tart`, as seen above) is applied by the `labels` key in `config.toml`.

### Future features if I feel like it
* Support PATs in addition to GitHub Apps (both classic and fine-grained)
* Support org-level runners instead of just repository runners (this is just a different endpoint)
* Make the launchd scripts better and have install/uninstall/status options.
* Make an entirely GHA compatible default image by exploiting their [existing packer scripts](https://github.com/actions/runner-images/blob/main/images/macos/templates). Images from Cirrus use user "admin", where GHA expects `/Users/runner`.

This project was built to fit the needs of [PyCA](https://github.com/pyca). Thanks to njs for the assistance with trio!
