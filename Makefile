# Software Name : abcdesktop.io
# Version: 0.2
# SPDX-FileCopyrightText: Copyright (c) 2020-2022 Orange
# SPDX-License-Identifier: GPL-2.0-only
#
# This software is distributed under the GNU General Public License v2.0 only
# see the "license.txt" file for more details.
#
# Author: abcdesktop.io team
# Software description: cloud native desktop service
#

##
# define a tag to build docker registry image
# the default tag is dev
# usage
# TAG=dev make
# TAG=latest make
#

ifndef TAG
 TAG=dev
endif

all: pyos

pyos:
	make -C var/pyos
	docker build --build-arg TAG=$(TAG) -t abcdesktopio/oc.pyos:$(TAG) .

push: 
	docker push abcdesktopio/oc.pyos:$(TAG)
