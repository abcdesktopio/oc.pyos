# oc.pyos

![Update oc.pyos](https://github.com/abcdesktopio/oc.pyos/workflows/Update%20oc.pyos/badge.svg)
![Docker Stars](https://img.shields.io/docker/stars/abcdesktopio/oc.pyos.svg)
![Docker Pulls](https://img.shields.io/docker/pulls/abcdesktopio/oc.pyos.svg)
![GNU GPL v2.0 License](https://img.shields.io/github/license/abcdesktopio/oc.pyos.svg)


## To get more informations

Please, read the public documentation web site:
* [https://www.abcdesktop.io](https://www.abcdesktop.io)
* [https://abcdesktopio.github.io/](https://abcdesktopio.github.io/)

## abcdesktop.io pyos API service, control plane

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

