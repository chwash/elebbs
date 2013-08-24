uses
    crt,
    timestmp,
    sysutils,
    longstr,
    wordstr;

var
   st1,
   en1 : real;
    x : longint;
    cmd : ShortString;

begin
    writeln('ExtractWord (1,000,000):');
    st1 := getmicroseconds;

    for x := 1 to 2000000 do
        begin
            str(x, cmd);
            cmd := '"foo bar" ' + cmd + '"abc" def "ghi"';
            ExtractWord(cmd, 3, defExtractWord, True, True);
        end;

    en1 := getMicroseconds;
    WriteLn('Time Elapsed: ', Real2Str(en1 - st1, 10, 15));


    writeln('FirstWord (500,000):');
    st1 := getmicroseconds;

    for x := 1 to 1000000 do
        begin
            str(x, cmd);
            cmd := '"foo bar" ' + cmd + '"abc" def "ghi"';
            FirstWord(cmd, defExtractWord, True);
        end;
    en1 := getMicroseconds;
    WriteLn('Time Elapsed: ', Real2Str(en1 - st1, 10, 15));


    writeln('LastWord (500,000):');
    st1 := getmicroseconds;

    for x := 1 to 1000000 do
        begin
            str(x, cmd);
            cmd := '"foo bar" ' + cmd + '"abc" def "ghi"';
            LastWord(cmd, defExtractWord, True);
        end;
    en1 := getMicroseconds;
    WriteLn('Time Elapsed: ', Real2Str(en1 - st1, 10, 15));


    writeln('RemoveWordNr (500,000):');
    st1 := getmicroseconds;

    for x := 1 to 1000000 do
        begin
            str(x, cmd);
            cmd := '"foo bar" ' + cmd + '"abc" def "ghi"';
            RemoveWordNr(cmd, 3, defExtractWord, True);
        end;
    en1 := getMicroseconds;
    WriteLn('Time Elapsed: ', Real2Str(en1 - st1, 10, 15));

    WriteLn('All done.');
    readln;
end.
