include .knightos/variables.make

# This is a list of files that need to be added to the filesystem when installing your program
ALL_TARGETS:=$(BIN)rubik $(APPS)rubik.app $(SHARE)icons/rubik.img

# This is all the make targets to produce said files
$(BIN)rubik: main.asm
	mkdir -p $(BIN)
	$(AS) $(ASFLAGS) --listing $(OUT)main.list main.asm $(BIN)rubik

$(APPS)rubik.app: rubik.app
	mkdir -p $(APPS)
	cp rubik.app $(APPS)

$(SHARE)icons/rubik.img: rubik.png
	mkdir -p $(SHARE)icons
	kimg -c rubik.png $(SHARE)icons/rubik.img

include .knightos/sdk.make
