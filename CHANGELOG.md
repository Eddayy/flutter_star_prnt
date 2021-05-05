## 2.3.0

- Credits to [Eldhose-Islet](https://github.com/Eldhose-Islet) for creating response status object PrinterResponseStatus
- Credits to [ImTung](https://github.com/ImTung) for creating StarMicronicsUtilities to find suitable emulations
- Deprecated Starprnt's print and checkstatus functions, use sendCommands and getStatus instead
- Add more comments

## 2.2.1

- Fix android port not released after used

## 2.2.0

- Added appendBitmapWidget function for print commands
- Added comment documentations of the print commands

## 2.1.0

- Android/IOS added appendBitmapByteArray
- Added appendBitmapByte function for print commands
- Added createimagefromwidget function for print commands

## 2.0.0

- Update to support null-safety

## 1.0.11

- Fix ios having issue scanning for bluetooth printers

## 1.0.10

- Fix ios appendbitmap scale and difussion settings

## 1.0.9

- Add Android appendbitmap to accept file path string

## 1.0.8

- Fix IOS appendbitmap not working for filepaths

## 1.0.7

- Change readme typo

## 1.0.6

- Add appendBitmap implementation for IOS

## 1.0.5

- This plugin now supports use_framework!

## 1.0.4

- Fixed crash cause by exceptions on android

## 1.0.3

- Fixed unable to find dependency on ios

## 1.0.2

- Fixed The 'Pods-Runner' target has transitive dependencies that include static frameworks bug

## 1.0.1

- Fixed Star sdk pod version for IOS

## 1.0.0

- Added portDiscovery, checkstatus and print function
