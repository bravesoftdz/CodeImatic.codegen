unit Output;

interface

Uses NovusLog, SysUtils, NovusUtilities, uPSRuntime, uPSUtils;

type
  Toutput = class(TNovusLogFile)
  private
  protected
    fsLastExParam: tbtstring;
    fLastExError: TPSError;
    fbErrors: Boolean;
    fbFailed: Boolean;
    fbconsoleoutputonly: Boolean;
  public
    procedure InitLog(AFilename: String; aOutputConsole: Boolean;
      aConsoleoutputonly: Boolean);

    procedure Log(const aMsg: string);
    procedure LogFormat(const aFormat: string; const Args: array of const);
    procedure LogError(const aMsg: String);

    procedure InternalError;
    procedure LogException(AException: Exception);

    property Errors: Boolean read fbErrors write fbErrors;

    property Failed: Boolean read fbFailed write fbFailed;

    property LastExError: TPSError read fLastExError write fLastExError;

    property LastExParam: tbtstring read fsLastExParam write fsLastExParam;

    property Consoleoutputonly: boolean read fbConsoleoutputonly write fbConsoleoutputonly default true;
  end;

implementation

procedure Toutput.InitLog(AFilename: String; aOutputConsole: Boolean;
  aConsoleoutputonly: Boolean);
begin
  OutputConsole := aOutputConsole;

  fbconsoleoutputonly := aConsoleoutputonly;

  Filename := AFilename;

  fbErrors := False;
end;

procedure Toutput.Log(const aMsg: string);
begin
  if fbconsoleoutputonly then
    Writeln(aMsg)
  else
    WriteLog(aMsg);
end;

procedure Toutput.LogError(const aMsg: String);
begin
  Log(aMsg);

  Failed := true;
end;

procedure Toutput.LogFormat(const aFormat: string; const Args: array of const);
begin
  Log(SysUtils.format(aFormat, Args));
end;

procedure Toutput.InternalError;
begin
  if fbconsoleoutputonly then
    Writeln(TNovusUtilities.GetExceptMess)
  else
    WriteExceptLog;

  Failed := true;
end;

procedure Toutput.LogException(AException: Exception);
var
  lsMessage: String;
begin
  if Not Assigned(AException) then
    Exit;

  lsMessage := 'Error:' + AException.Message;

  Log(lsMessage);

  Failed := true;
end;

end.

