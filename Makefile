install:
	swift build -c release
	install .build/Release/ink-cli /usr/local/bin/ink
