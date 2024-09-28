unit uuidv7_tests;

interface

uses
  DUnitX.TestFramework,
  DateUtils,
  SysUtils;

type
  [TestFixture]
  TUUIDv7Test = class(TObject)
  public
    [Test]
    procedure TestUUIDv7Timestamp;
    [Test]
    procedure TestUUIDv7Version;
    [Test]
    procedure TestUUIDv7Variant;
  end;

implementation

uses
  uuidv7;

procedure TUUIDv7Test.TestUUIDv7Timestamp;
begin

  var uuid := GenerateUUIDv7;

  // Extract the timestamp from the UUID
  var extractedTimestamp := (Int64(uuid.D1) shl 12) or (Int64(uuid.D2) and $0FFF);
  extractedTimestamp := (extractedTimestamp shl 4) or (Int64(uuid.D3) shr 12);

  var timestamp := DateTimeToUnix(Now) * 1000;

  // Allow for some variance due to processing time
  Assert.IsTrue(Abs(extractedTimestamp - timestamp) < 1000,
    'Timestamp is not correctly placed in the UUID');
end;

procedure TUUIDv7Test.TestUUIDv7Variant;
begin
  var uuid := GenerateUUIDv7;

  // Extract the variant (top 2 bits of D4[0])
  var Variant: Byte := (uuid.D4[0] and $C0) shr 6;

  // Validate the variant is 2 (RFC 4122 variant = 10xxxxxx)
  Assert.AreEqual(Byte(2), Variant);
end;

procedure TUUIDv7Test.TestUUIDv7Version;
begin
  var uuid := GenerateUUIDv7;

  // Extract version (bits 48-51 in the 16-byte structure)
  var version: word := (uuid.D2 and $F000) shr 12;

  Assert.AreEqual(7, version)
end;

initialization
  TDUnitX.RegisterTestFixture(TUUIDv7Test);
  TDUnitX.Options.ExitBehavior := TDUnitXExitBehavior.Pause;

end.


