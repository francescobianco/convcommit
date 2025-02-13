
install:
	@mush install --path .

release:
	@mush build --release
	@git add .
	@git commit -m "$(shell convcommit)" || true
	@git push

test-message:
	@#rm .convcommit || true
	@MESSAGE=$$(mush run) && echo "Message --> $$MESSAGE"
