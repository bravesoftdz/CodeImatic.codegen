{$I Zcodegen.inc}
program Zcodegen;

{$APPTYPE CONSOLE}

uses
  Sharemem,
  System.SysUtils,
  Config,
  output,
  runtime,
  project,
  projectconfig,
  DBSchema in 'DBSchema.pas',
  Properties in 'Properties.pas',
  CodeGenerator in 'CodeGenerator.pas',
  Interpreter in 'Interpreter.pas',
  Language in 'Language.pas',
  Variables in 'Variables.pas',
  Reservelist in 'Reservelist.pas',
  XMLList in 'XMLList.pas',
  Plugins in 'Plugins.pas',
  PluginsMapFactory in 'PluginsMapFactory.pas';

{$R *.res}

begin
  oConfig.LoadConfig;

  If Not oConfig.ParseParams then Exit;

  try
   ExitCode := oruntime.RunEnvironment;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
