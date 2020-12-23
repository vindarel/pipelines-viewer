LISP ?= sbcl

build:
	$(LISP) --load pipelines-viewer.asd \
	     --eval '(ql:quickload :pipelines-viewer)' \
	     --eval '(asdf:make :pipelines-viewer)' \
	     --eval '(quit)'

# run:
	# rlwrap $(LISP) --load pipelines-viewer.asd
