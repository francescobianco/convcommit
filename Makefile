
install:
	@mush install --path .

release:
	@mush build --release
	@convcommit -a -p

test-message:
	@#rm .convcommit || true
	@MESSAGE=$$(mush run) && echo "Message --> $$MESSAGE"
