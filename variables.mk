# Print variables available in the current context and their origins
.PHONY: variables
variables:
	@$(foreach \
		v, \
		$(sort $(.VARIABLES)), \
		$(if \
			$(filter-out \
				environment% default automatic, \
				$(origin $v)), \
			$(info $v = $($v) ($(value $v)))))
	@true

# Print a single variable and its origin
.PHONY: variable-%
variable-%:
	$(info $* = $($*) ($(value $*)))
	@true
