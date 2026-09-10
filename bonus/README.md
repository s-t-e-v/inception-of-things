# GitLab bonus

This bonus installs a lightweight local GitLab in the Part 3 k3d cluster and
lets Argo CD deploy the same application from GitLab instead of GitHub.

## Run it

Run the following commands from this directory:

```sh
cd bonus
```

Install the required tools once:

```sh
make install
```

Create the cluster and install GitLab:

```sh
make setup
```

Open <http://gitlab.localhost> and print the initial login with:

```sh
make credentials
```

Copy the Part 3 repository to GitLab and switch Argo CD to that copy:

```sh
make argocd-gitlab
```

The GitLab project is available at
<http://gitlab.localhost/root/argocd-app-sbandaog>.

Restore Argo CD's original GitHub source with:

```sh
make argocd-github
```

Use `make help` to list the optional status, UI, SSH, repository, and cleanup
commands.

## Prove Garage object storage

GitLab uses the `git-lfs` Garage bucket while the other optional object-storage
features remain disabled. Run the isolated demonstration with:

```sh
make garage-demo
```

This creates the private `root/garage-lfs-demo` project, pushes
`assets/garage-demo.png` as a Git LFS object, fresh-clones it, verifies its
contents, and prints the Garage bucket statistics. The command is safe to run
again and does not modify the Argo CD repository.

## Important

`make recreate` deletes and recreates the k3d cluster. GitLab data is stored in
cluster-local volumes, so repositories and accounts are deleted with the
cluster.
