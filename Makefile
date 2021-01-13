NOCACHE := "false"

ifdef $$NOCACHE
  NOCACHE := $$NOCACHE
endif


all: pyos

pyos:
	make -C var/pyos
	docker build --no-cache -t oc.pyos -f oc.pyos .
	docker tag oc.pyos abcdesktop/oio:oc.pyos

push: 
	docker push abcdesktop/oio:oc.pyos
