program uuidv7_example;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  uuidv7 in '..\uuidv7\src\uuidv7.pas',
  DateUtils;

procedure DisplayUUIDv7(UUID: TGUID);
begin
  writeln(GUIDToString(uuid).ToLower.Trim(['{','}']));
  writeln('└─timestamp─┘ │└─┤ │└───rand_b─────┘'+sLineBreak+
          '             ver │var'+sLineBreak+
          '              rand_a');
end;

procedure TestUUIDv7;
var
  uuid: TGUID;
  version: Integer;
  variant: Integer;
  timestamp: Int64;
  nowMillis: Int64;
begin
  // Generate a UUIDv7
  uuid := GenerateUUIDv7;
  Writeln('Testing....');
  DisplayUUIDv7(uuid);

  // Extract version (bits 48-51 in the 16-byte structure)
  version := (uuid.D2 and $F000) shr 12;

  Write('Version #',version);
  // Validate the version is 7
  if version <> 7 then
    Writeln('...INVALID! Expected 7')
  else
    Writeln('...Pass');

  // Extract the variant (top 2 bits of D4[0])
  variant := (uuid.D4[0] and $C0) shr 6;
  Write('Variant #',Variant);

  // Validate the variant is 2 (RFC 4122 variant = 10xxxxxx)
  if variant <> 2 then
    writeln('...INVALID! Expected 2')
  else
    writeln('...Pass');

  // Extract the timestamp from the first 48 bits
  //timestamp := (Int64(uuid.D1) shl 16) or (uuid.D2 and $0FFF);

  Timestamp := (Int64(uuid.D1) shl 12) or (Int64(uuid.D2) and $0FFF);
  Timestamp := (Timestamp shl 4) or (Int64(uuid.D3) shr 12);

  writeln('Timestamp: ',IntToHex(timestamp));

  // Get the current time in milliseconds since Unix epoch
  nowMillis := DateTimeToMilliseconds(Now) - Int64(UnixDateDelta + DateDelta) * MSecsPerDay;
  var drift := Abs(nowMillis - timestamp);
  Write('Drift: ',drift, 'ms');

  // Check the timestamp is close to the current time (within a reasonable threshold)
  if drift > 10 then // Allow for 100 ms drift
    Writeln('...INVALID! Expected < 10ms drift')
  else
    Writeln('...Pass');
end;

begin
  try
    for var i := 0 to 18 do
    begin
      writeln(GUIDToString(GenerateUUIDv7).ToLower.Trim(['{','}']));
      sleep(Random(9)+1)
    end;
    TestUUIDv7;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  readln;
end.
