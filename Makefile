PREFIX = /usr/local/bin

source_file = $(wildcard $(notdir $(CURDIR)).*)
source_path = $(CURDIR)/$(source_file)
target_file = $(basename $(source_file))
target_path = $(PREFIX)/$(target_file)

.PHONY: test
test:
	$(CURDIR)/test.sh

.PHONY: install
install:
	install $(source_path) $(target_path)
	sed -i -e 's/\(\.\/\)\?$(source_file)/$(target_file)/g' $(target_path)

include tools.mk
