PREFIX = /usr/local
DESTDIR = $(PREFIX)

CURL = /usr/bin/curl
INSTALL = /usr/bin/install
MKDIR = /usr/bin/mkdir
SED = /usr/bin/sed

SHUNIT2_VERSION = 2.1.6

bin_directory = $(PREFIX)/bin

name = $(notdir $(CURDIR))
include_directory = $(PREFIX)/share/$(name)
include_destination_directory = $(DESTDIR)/share/$(name)

source_path = fgit.sh
target_path = $(bin_directory)/$(name)

shunit2_dir = shunit2-source
shunit2 = $(shunit2_dir)/$(SHUNIT2_VERSION)/src/shunit2
export shunit2

.PHONY: test
test: $(shunit2)
	$(CURDIR)/test.sh

.PHONY: install
install:
	$(INSTALL) -D $(source_path) $(target_path)
	$(INSTALL) -D --target-directory=$(include_directory) shell-includes/error.sh shell-includes/usage.sh shell-includes/variables.sh shell-includes/warning.sh
	$(SED) -i'' 's#^\(includes=\).*#\1"$(include_destination_directory)"#' $(target_path)

$(shunit2):
	$(CURL) --silent --location "https://github.com/kward/shunit2/archive/source.tar.gz" | tar --extract --gzip

clean:
	$(RM) --recursive $(shunit2_dir)

include make-includes/variables.mk
