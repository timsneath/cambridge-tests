# Cambridge Project
The Cambridge project can be found at https://github.com/timsneath/cambridge.

This repo creates unit tests to exercise the Z80 emulator that is contained within it. 

## Unit Test Creation
The FUSE emulator contains a large unit test suite of over 1,300 tests,
which cover both documented and undocumented opcodes:
   http://fuse-emulator.sourceforge.net/ 

The tests are delivered in two files: a tests.in file that contains test 
inputs and a tests.expected that gives the expected output state for the 
Z80 processor. 

This project loads them from disk and creates Dart unit tests out
of the results. 

### Instructions

1. Execute the command utility CreateUnitTests.dart, having adjusted the 
   location of the test files and output as appropriate

2. Copy the resultant fusetests.dart to the Cambridge EmulatorTests/tests 
folder and run it with
```
   pub run test tests/fuse-tests.dart
```