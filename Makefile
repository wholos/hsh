HS=ghc

all:
	@echo "Build..."
	@$(HS) main.hs

clean:
	@echo "Clean..."
	@rm main
	@rm main.hi
	@rm main.o
