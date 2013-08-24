{$S-,R-,I-,F+,V-}
{$M 16384, 0, 655360}

{Conditional defines that may affect this unit}
{$I APDEFINE.INC}

{Activate *one* of the following defines}
{.$DEFINE DemoXYModem}
{.$DEFINE DemoZmodem}
{.$DEFINE DemoKermit}
{$DEFINE DemoBPlus}

{*********************************************************}
{*                    TTERMO.PAS 2.03                    *}
{*     Copyright (c) TurboPower Software 1991.           *}
{*                 All rights reserved.                  *}
{*********************************************************}

program TTermO;
  {-Shows how to manage BACKO TSR from foreground program}

uses
  {--- RTL  ---}
  Dos,
  {--- OPRO ---}
  OpRoot,
  OpCrt,
  OpString,
  OpInt,
  OpTsr,
  {--- APRO ---}
  ApTimer,
  ApMisc,
  ApPort,
  ApUart,
  ApAnsi,
  OoCom,
  OoAbsPcl;

type
  TransferType = (tmTransmit, tmReceive);

  {NOTE: This record format must be the same as BACKO's PInfo record}
  {Protocol information record}
  {Protocol information record}
  ProtInfoPtr = ^ProtInfoRec;
  ProtInfoRec = record
    TransferMode  : TransferType;  {Transmit or receive}
    FName         : PathStr;       {Holds filename (if needed)}
    {$IFDEF DemoXYModem}
    Prot          : Byte;          {Type of protocol requested}
    Use1KBlocks   : Boolean;       {True if 1K mode requested}
    UseGMode      : Boolean;       {True if Gmode requested}
    {$ENDIF}
    {$IFDEF DemoZmodem}
    ClobberFile   : Boolean;       {True to overwrite existing files}
    ResumeFile    : Boolean;       {True to resume previous transfer}
    NewerLonger   : Boolean;       {True to overwrite only if newer or longer}
    {$ENDIF}
  end;

  {General pointer record}
  OS = record
    O : Word;
    S : Word;
  end;

const
  ModuleName   : String[6] = 'BACKO';
  HdrAttr      = $1F;

  MainHdr = 'TTERMO 2.03 - A demonstration terminal program that uses the BACKO TSR';
  MainStatus = ' <AltX> - exit   <PgUp> - upload via BACKO   <PgDn> - download via ZBACKO';

  PgDn = #$51;
  PgUp = #$49;
  AltX = #$2D;

var
  ComPort    : UartPortPtr;
  C          : Char;
  Finished   : Boolean;
  PInfo      : ProtInfoPtr;
  Regs       : IntRegisters;
  ExtIfcPtr  : IfcPtr;
  InProgress : Boolean;

procedure Abort(Msg : String; Code : Integer);
  {-Close port and halt}
begin
  WriteLn(Msg, Code);
  Halt(1);
end;

procedure Beep;
begin
  Sound(700);
  Delay(100);
  NoSound;
end;

begin
  {Open a port}
  New(ComPort, InitCustom(Com3, 2400, NoParity, 8, 1, 2000, 2000, DefPortOptions));
  if ComPort = nil then
    Abort('Failed to open port: ', AsyncStatus);

  {See if BACKO is loaded}
  ExtIfcPtr := ModulePtrByName(ModuleName);

  {Show header and status lines}
  ClrScr;
  FastWrite(Center(MainHdr,ScreenWidth), 1, 1, HdrAttr);
  FastWrite(Center(MainStatus, ScreenWidth), ScreenHeight, 1, HdrAttr);
  Window(1, 2, ScreenWidth, ScreenHeight-1);

  {Simple terminal}
  Finished := False;
  InProgress := False;
  repeat
    {Process chars to send}
    if KeyPressed then begin
      C := ReadKey;
      if C = #0 then begin
        C := ReadKey;
        case C of
          PgUp :
            begin
              if ExtIfcPtr <> nil then begin
                {Allocate and fill in a PInfo record}
                if not GetMemCheck(PInfo, SizeOf(PInfo^)) then
                  Abort('Out of memory ', 1);
                with PInfo^ do begin
                  TransferMode := tmTransmit;
                  FName := 'TTERMO.PAS';
                  {$IFDEF DemoXYModem}
                  Prot := Xmodem;
                  Use1KBlocks := True;
                  UseGMode := False;
                  {$ENDIF}
                  {$IFDEF DemoZmodem}
                  ClobberFile := False;
                  ResumeFile := False;
                  NewerLonger := True;
                  {$ENDIF}
                end;
                Regs.ES := OS(PInfo).S;
                Regs.DI := OS(PInfo).O;
                Regs.AH := 2; {Start protocol}
                EmulateInt(Regs, ExtIfcPtr^.CmdEntryPtr);
                InProgress := True;

                WriteLn;
                WriteLn;
                WriteLn('Protocol upload requested via BACKO');
                WriteLn('Press <CtrlShift<S> for status display');
                WriteLn('Press <CtrlShift<X> to cancel');
                WriteLn('Do *not* exit TTERMO until protocol is complete');
                WriteLn;

              end else
                Beep;
            end;

          PgDn :
            begin
              if ExtIfcPtr <> nil then begin
                {Allocate and fill in a PInfo record}
                if not GetMemCheck(PInfo, SizeOf(PInfo^)) then
                  Abort('Out of memory ', 1);
                with PInfo^ do begin
                  TransferMode := tmReceive;
                  FName := '';
                  {$IFDEF DemoXYModem}
                  Prot := Ymodem;
                  Use1KBlocks := True;
                  UseGMode := False;
                  {$ENDIF}
                  {$IFDEF DemoZmodem}
                  ClobberFile := False;
                  ResumeFile := False;
                  NewerLonger := True;
                  {$ENDIF}
                end;
                Regs.ES := OS(PInfo).S;
                Regs.DI := OS(PInfo).O;
                Regs.AH := 2; {Start protocol}
                EmulateInt(Regs, ExtIfcPtr^.CmdEntryPtr);
                InProgress := True;

                WriteLn;
                WriteLn;
                WriteLn('Protocol download requested via BACKO');
                WriteLn('Press <CtrlShift<S> for status display');
                WriteLn('Press <CtrlShift<X> to cancel');
                WriteLn('Do *not* exit TTERMO until protocol is complete');
                WriteLn;

              end else
                Beep;
            end;

          AltX :
            Finished := True;
        end;
      end else begin
        if ComPort^.TransReady then
          ComPort^.PutChar(C);
      end;
    end;

    {Process chars received}
    if ComPort^.CharReady then begin
      ComPort^.GetChar(C);
      WriteCharAnsi(C);
    end;

    {if protocol is in progress check for completion}
    if InProgress then begin
      Regs.AH := 3; {Progress check}
      EmulateInt(Regs, ExtIfcPtr^.CmdEntryPtr);
      if not Boolean(Regs.AH) then begin
        WriteLn;
        WriteLn('Protocol is complete');
        WriteLn;
        InProgress := False;
      end;
    end;
  until Finished;

  Dispose(ComPort, Done);
  Window(1, 1, ScreenWidth, ScreenHeight);
  ClrScr;
end.
