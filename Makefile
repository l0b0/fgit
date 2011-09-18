PREFIX = /usr/local/bin
FILE_PATH = $(CURDIR)/fgit.sh
INSTALL_FILE_PATH = $(PREFIX)/fgit

.PHONY: test
test:
	$(CURDIR)/tests.sh

$(INSTALL_FILE_PATH):
	cp $(FILE_PATH) $(INSTALL_FILE_PATH)

.PHONY: install
install: $(INSTALL_FILE_PATH)

include tools.mk
