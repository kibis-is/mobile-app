all: install

build-android:
	flutter build aab --release

build-android-debug:
	flutter build aab --debug

build-ios:
	flutter build ios --release

install:
	flutter pub get

start:
	flutter run
