PREFIX = /usr/local/bin

SCRIPT = $(notdir $(CURDIR)).sh
FILE_PATH = $(CURDIR)/$(SCRIPT)
INSTALL_FILE_PATH = $(PREFIX)/$(basename $(SCRIPT))

.PHONY: test
test:
	$(CURDIR)/test.sh

.PHONY: install
install:
	cp $(FILE_PATH) $(INSTALL_FILE_PATH)

include tools.mk
