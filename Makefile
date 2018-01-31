PREFIX = /usr/local
DESTDIR = $(PREFIX)

INSTALL = /usr/bin/install
SED = /usr/bin/sed

name = $(notdir $(CURDIR))

target_path = $(PREFIX)/bin/$(name)

.PHONY: test
test:
	$(CURDIR)/test.sh

.PHONY: install
install:
	$(INSTALL) -D fgit.sh $(target_path)
	$(INSTALL) -D --target-directory=$(PREFIX)/share/$(name) shell-includes/error.sh shell-includes/usage.sh shell-includes/variables.sh shell-includes/warning.sh
	$(SED) -i'' 's#^\(includes=\).*#\1"$(DESTDIR)/share/$(name)"#' $(target_path)

include make-includes/variables.mk
