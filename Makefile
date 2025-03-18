.PHONY: test

test:
	nvim --headless --noplugin -u scripts/minimal-init.vim -c "PlenaryBustedDirectory tests/ { minimal_init = './scripts/minimal-init.vim' }"
