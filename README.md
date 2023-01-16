# CiderMill
This project orchestrates ephemeral runners for GHA on macOS arm64 using [tart](https://github.com/cirruslabs/tart).

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
* Copy `config.toml.example` to `config.toml` and fill it out. `base_image_name` is the name of the image you built in the previous step
* Create a virtualenv and install the dependencies into it: `python -m venv venv && venv/bin/pip install -r requirements.txt`
* Run it! `venv/bin/python server.py`

If you don't want to manually invoke, see the next section.

## Running via launchd

There is a helper script called `svc.sh`, which contains tools for executing this via launchd. You **must** install the dependencies into a virtual environment named `venv` as described above or else this will fail due to bad paths.

* `echo $PATH > .path` from a shell where the basic invocation works (e.g. you have all the expected `PATH`). This will create a file that `server.py` loads to populate its own `PATH` at runtime. This is useful in contexts where you don't have a login shell (e.g. a launchd agent like we're currently creating)
* Run `./svc.sh install` to install the launchd agent.
* Run `./svc.sh start` to start it up.

`svc.sh` supports the following commands:
* install -- Creates and installs the launchd plist.
* uninstall -- Stops the service and deletes the plist.
* start -- Starts the previously installed service.
* stop -- It is a mystery.
* status -- Tells you whether the service is installed and whether launchctl thinks it is running.
* tail -- Prints the tail command so you can look at the logs. Why doesn't it simply tail it? I am bad at shell, that's why.

**Note:** If you're running on Ventura you may see a "Background Items Added" message appear when you install the plist (it moves the file into `~/Library/LaunchAgents`). Depending on whether the Python you're using is code signed you might see an odd message like "Software from "Ned Deily"". Good times.

## Using it
Once you have a connected runner you can invoke it from a workflow with the correct runs-on key:

>    runs-on: [self-hosted, macos, ARM64, tart]

The GitHub Actions runner will automatically apply the first 3 tags, but any other tag (including `tart`, as seen above) is applied by the `labels` key in `config.toml`.

### Future features if I feel like it
* Support PATs in addition to GitHub Apps (both classic and fine-grained)
* Support org-level runners instead of just repository runners (this is just a different endpoint)
* Make an entirely GHA compatible default image by exploiting their [existing packer scripts](https://github.com/actions/runner-images/blob/main/images/macos/templates). Images from Cirrus use user "admin", where GHA expects `/Users/runner`. Our packer scripts create an empty `/Users/runner` to fool things like `setup-python`, but there's no guarantee of broad compatibility.

This project was built to fit the needs of [PyCA](https://github.com/pyca). Thanks to njs for the assistance with trio!

### FAQ
**How do I delete the old runners from GitHub?**
GitHub automatically cleans up ephemeral runners one day after they last connected.

**How do I make a GitHub application and what permissions does it need?**
The [actions-runner-controller](https://github.com/actions/actions-runner-controller) folks have [good documentation](https://github.com/actions/actions-runner-controller/blob/2e406e3aefa8dad6e2b8926a3bbc51b613aa1af1/docs/authenticating-to-the-github-api.md) about the permissions required along with some links.
