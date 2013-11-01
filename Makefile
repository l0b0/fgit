PREFIX = /usr/local
bin_directory = $(PREFIX)/bin
share_directory = $(PREFIX)/share

name = $(notdir $(CURDIR))
include_directory = $(share_directory)/$(name)

source_file = $(wildcard $(name).*)
source_path = $(CURDIR)/$(source_file)
target_path = $(bin_directory)/$(name)

.PHONY: test
test:
	$(CURDIR)/test.sh

.PHONY: install
install: $(include_directory)
	install $(source_path) $(target_path)
	install shell-includes/error.sh shell-includes/usage.sh shell-includes/variables.sh shell-includes/warning.sh $(include_directory)
	sed -i -e 's/\(\.\/\)\?$(source_file)/$(target_file)/g' $(target_path)
	sed -i -e 's#^\(includes=\).*#\1"$(include_directory)"#' $(target_path)

$(include_directory):
	mkdir $(include_directory)

include tools.mk
