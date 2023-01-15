# Building a Tart VM
This section explains how to build a macOS VM for use with CiderMill. Check out the parent README for more information.

## Setup and Installation
This builds OCI compatible images that can be pushed to OCI registries, but chances are you just want to keep a local copy, so this guide assumes you're going to run these commands on the same host that you are going to spawn VMs. If that's not the case, congratulations on your operational maturity and I hope you have a lot of bandwidth.

* Install packer (`brew install packer`)
* Install the tart plugin for packer with `packer init runner.pkr.hcl`
* Copy the SSH public key you want trusted into a file named``runner_authorized_keys` in this directory.

Now we need to modify the `runner.pkr.hcl` file with the items that matter for your use case. Cirrus Labs (creators of tart) provide a useful base image, which you'll see in `vm_base_name`. If you'd like to see how that's created (or see more complex examples) take a look at their [macos-image-templates](https://github.com/cirruslabs/macos-image-templates) repository. You can also select from a few alternate base images by looking at their [list](https://github.com/orgs/cirruslabs/packages?tab=packages&q=macos-).

The default `runner.pkr.hcl` configuration installs Python 3.11 as an example, but feel free to delete that. Do not, however, delete the SSH key copying.

Once you've configured the build to your liking run `packer build -var name=NAME runner.pkr.hcl` where `NAME` is what you want to name your base image. You will use this name again for the `base_image` value in `config.toml`.
