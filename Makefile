PREFIX = /usr/local
DESTDIR = $(PREFIX)

INSTALL = /usr/bin/install
MKDIR = /usr/bin/mkdir
SED = /usr/bin/sed

bin_directory = $(PREFIX)/bin

name = $(notdir $(CURDIR))
include_directory = $(PREFIX)/share/$(name)
include_destination_directory = $(DESTDIR)/share/$(name)

source_path = fgit.sh
target_path = $(bin_directory)/$(name)

.PHONY: test
test:
	$(CURDIR)/test.sh

.PHONY: install
install:
	$(INSTALL) -D $(source_path) $(target_path)
	$(INSTALL) -D --target-directory=$(include_directory) shell-includes/error.sh shell-includes/usage.sh shell-includes/variables.sh shell-includes/warning.sh
	$(SED) -i'' 's#^\(includes=\).*#\1"$(include_destination_directory)"#' $(target_path)

include make-includes/variables.mk
