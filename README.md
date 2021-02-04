# oc.pyos
abcdesktop.io pyos API service
![Docker Stars](https://img.shields.io/docker/stars/abcdesktopio/oc.pyos.svg) ![Docker Pulls](https://img.shields.io/docker/pulls/abcdesktopio/oc.pyos.svg)


Docker container to build the oc.pyos image

oc.pyos depend pyos submodule in /var directory 

```
[submodule "var/pyos"]
	path = var/pyos
	url = https://github.com/abcdesktopio/pyos.git
	branch = main
```

## To build the Docker container oc.pyos image manually

* oc.pyos is the docker container for pyos.
* pyos is a git submodule in oc.pyos, git clone must add the --recurse-submodules option

```
git clone --recurse-submodules https://github.com/abcdesktopio/oc.pyos.git
docker build  -t abcdesktopio/oc.pyos -f oc.pyos .
```

