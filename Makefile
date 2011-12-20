PREFIX = /usr/local/bin
FILE_PATH = $(CURDIR)/fgit.sh
INSTALL_FILE_PATH = $(PREFIX)/fgit

.PHONY: test
test:
	$(CURDIR)/tests.sh

.PHONY: install
install:
	cp $(FILE_PATH) $(INSTALL_FILE_PATH)

include tools.mk
