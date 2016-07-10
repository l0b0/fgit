PREFIX = /usr/local

CURL = /usr/bin/curl
INSTALL = /usr/bin/install
MKDIR = /usr/bin/mkdir
SED = /usr/bin/sed

SHUNIT2_VERSION = 2.1.6

bin_directory = $(PREFIX)/bin
share_directory = $(PREFIX)/share

name = $(notdir $(CURDIR))
include_directory = $(share_directory)/$(name)

source_file = $(wildcard $(name).*)
source_path = $(CURDIR)/$(source_file)
target_path = $(bin_directory)/$(name)

shunit2_dir = shunit2-source
shunit2 = $(shunit2_dir)/$(SHUNIT2_VERSION)/src/shunit2
export shunit2

.PHONY: test
test: $(shunit2)
	$(CURDIR)/test.sh

.PHONY: install
install: $(include_directory)
	$(INSTALL) $(source_path) $(target_path)
	$(INSTALL) shell-includes/error.sh shell-includes/usage.sh shell-includes/variables.sh shell-includes/warning.sh $(include_directory)
	$(SED) -i'' 's#^\(includes=\).*#\1"$(include_directory)"#' $(target_path)

$(shunit2):
	$(CURL) --silent --location "https://github.com/kward/shunit2/archive/source.tar.gz" | tar --extract --gzip

$(include_directory):
	$(MKDIR) $(include_directory)

clean:
	$(RM) --recursive $(shunit2_dir)

include make-includes/variables.mk
