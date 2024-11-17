all: install

build-android:
	flutter build aab --release

build-ios:
	flutter build ios --release

install:
	flutter pub get

start:
	flutter run
