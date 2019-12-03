install:
	swift build -c release
	install .build/release/ink-cli /usr/local/bin/ink
