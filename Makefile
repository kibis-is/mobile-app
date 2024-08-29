scripts_dir := ./scripts

all: clean install

clean:
	flutter clean

install:
	flutter pub get
	$(scripts_dir)/post_install.sh
