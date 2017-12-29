import 'dart:io';

const bool includeUndocumentedOpcodeUnitTests = false;

String toHex(int value) => value.toRadixString(16).padLeft(2, '0');

main() async {
  var file = new File('../cambridge/EmulatorDart/test/fuse_unit_test.dart');
  var sink = file.openWrite();

  String testName;

  sink.write(r"""
import 'package:test/test.dart';
import '../z80.dart';
import '../memory.dart';
import '../utility.dart';

Memory memory = new Memory();
Z80 z80 = new Z80(memory, startAddress: 0xA000);

void Poke(int addr, int val) => memory.writeByte(addr, val);
int Peek(int addr) => memory.readByte(addr);

void LoadRegisters(int af, int bc, int de, int hl, int af_, int bc_, int de_,
    int hl_, int ix, int iy, int sp, int pc) {
  z80.af = af;
  z80.bc = bc;
  z80.de = de;
  z80.hl = hl;
  z80.a_ = highByte(af_);
  z80.f_ = lowByte(af_);
  z80.b_ = highByte(bc_);
  z80.c_ = lowByte(bc_);
  z80.d_ = highByte(de_);
  z80.e_ = lowByte(de_);
  z80.h_ = highByte(hl_);
  z80.l_ = lowByte(hl_);
  z80.ix = ix;
  z80.iy = iy;
  z80.sp = sp;
  z80.pc = pc;
}

main() {
  setUp(() {
    z80.reset();
    memory.reset();
  });
  tearDown(() {});
  """);

  // These unit tests stress undocumented Z80 opcodes
  var undocumentedOpcodeTests = [
    "4c",
    "4e",
    "54",
    "5c",
    "63",
    "64",
    "6b",
    "6c",
    "6e",
    "70",
    "71",
    "74",
    "7c",
    "cb30",
    "cb31",
    "cb32",
    "cb33",
    "cb34",
    "cb35",
    "cb36",
    "cb37",
    "dd24",
    "dd25",
    "dd26",
    "dd2c",
    "dd2d",
    "dd2e",
    "dd44",
    "dd45",
    "dd4c",
    "dd4d",
    "dd54",
    "dd55",
    "dd5c",
    "dd5d",
    "dd60",
    "dd61",
    "dd62",
    "dd63",
    "dd64",
    "dd65",
    "dd67",
    "dd68",
    "dd69",
    "dd6a",
    "dd6b",
    "dd6c",
    "dd6d",
    "dd6f",
    "dd7c",
    "dd7d",
    "dd84",
    "dd85",
    "dd8c",
    "dd8d",
    "dd94",
    "dd95",
    "dd9c",
    "dd9d",
    "dda4",
    "dda5",
    "ddac",
    "ddad",
    "ddb4",
    "ddb5",
    "ddbc",
    "ddbd",
    "ddfd00",
    "fd24",
    "fd25",
    "fd26",
    "fd2c",
    "fd2d",
    "fd2e",
    "fd44",
    "fd45",
    "fd4c",
    "fd4d",
    "fd54",
    "fd55",
    "fd5c",
    "fd5d",
    "fd60",
    "fd61",
    "fd62",
    "fd63",
    "fd64",
    "fd65",
    "fd67",
    "fd68",
    "fd69",
    "fd6a",
    "fd6b",
    "fd6c",
    "fd6d",
    "fd6f",
    "fd7c",
    "fd7d",
    "fd84",
    "fd85",
    "fd8c",
    "fd8d",
    "fd94",
    "fd95",
    "fd9c",
    "fd9d",
    "fda4",
    "fda5",
    "fdac",
    "fdad",
    "fdb4",
    "fdb5",
    "fdbc",
    "fdbd",
    "ddcb36",
    "fdcb36"
  ];

  // These too...
  for (int opCode = 0; opCode < 256; opCode++) {
    if ((opCode & 0x7) != 0x6) {
      undocumentedOpcodeTests.add("ddcb${toHex(opCode)}");
      undocumentedOpcodeTests.add("fdcb${toHex(opCode)}");
    }
  }

  List<String> input = await new File('tests.in').readAsLines();
  List<String> expected = await new File('tests.expected').readAsLines();

  try {
    int inputLine = 0;
    int expectedLine = 0;

    while (inputLine < input.length) {
      testName = input[inputLine++];

      sink.write("  test('$testName', () {\n");

      var registers = input[inputLine++].split(' ');
      sink.write("    LoadRegisters(");
      sink.write("0x${registers[0]}, ");
      sink.write("0x${registers[1]}, ");
      sink.write("0x${registers[2]}, ");
      sink.write("0x${registers[3]}, ");
      sink.write("0x${registers[4]}, ");
      sink.write("0x${registers[5]}, ");
      sink.write("0x${registers[6]}, ");
      sink.write("0x${registers[7]}, ");
      sink.write("0x${registers[8]}, ");
      sink.write("0x${registers[9]}, ");
      sink.write("0x${registers[10]}, ");
      sink.write("0x${registers[11]});\n");

      var special = input[inputLine++].split(' ');
      sink.write("    z80.i = 0x${special[0]};\n");
      sink.write("    z80.r = 0x${special[1]};\n");
      sink.write("    z80.iff1 = ${special[2] == '1' ? 'true' : 'false'};\n");
      sink.write("    z80.iff2 = ${special[3] == '1' ? 'true' : 'false'};\n");
      int testRunLength = int.parse(special[6]);

      while (!input[inputLine].startsWith('-1')) {
        var pokes = input[inputLine].split(' ');
        var addr = int.parse(pokes[0], radix: 16);
        var idx = 1;
        while (pokes[idx] != '-1') {
          sink.write("    Poke($addr, 0x${pokes[idx]});\n");
          idx++;
          addr++;
        }
        inputLine++;
      }
      inputLine++;
      inputLine++;

      sink.write("    while(z80.tStates < ${testRunLength}) {\n");
      sink.write("      z80.executeNextInstruction();");
      sink.write("    }");
      sink.write("  }\n\n");

      if (undocumentedOpcodeTests.contains(testName)) {}
    }

    sink.write(r"""
}
  """);
  } finally {
    sink.close();
  }
}
