unit Plugin_SysTagsClasses;

interface

uses Classes,Plugin, NovusPlugin, NovusVersionUtils, Project,
    Output, SysUtils, System.Generics.Defaults,  runtime, Config,
    APIBase, NovusGUIDEx, CodeGeneratorItem;


type
  TSysTag = class
  private
  protected
     function GetTagName: String; virtual;
  public
     function Execute(aCodeGeneratorItem: TCodeGeneratorItem): String; virtual;
  
     property TagName: String
       read GetTagName;
  end;

  TSysTag_Version = class(TSysTag)
  private
  protected
    function GetTagName: String; override;
  public 
    function Execute(aCodeGeneratorItem: TCodeGeneratorItem): String; override;
  end;

  TSysTag_FilePathToURL = class(TSysTag)
  private
  protected
    function GetTagName: String; override;
  public 
    function Execute(aCodeGeneratorItem: TCodeGeneratorItem): String; override;
  end;

  TSysTag_newguid = class(TSysTag)
  private
  protected
    function GetTagName: String; override;
  public
    function Execute(aCodeGeneratorItem: TCodeGeneratorItem): String; override;
  end;

  TSysTag_NewguidNoBrackets = class(TSysTag)
  private
  protected
    function GetTagName: String; override;
  public 
    function Execute(aCodeGeneratorItem: TCodeGeneratorItem): String; override;
  end;

  tSysTags = array of TSysTag;

  tPlugin_SysTagsBase = class(TTagsPlugin)
  private
  protected
    FSysTags: tSysTags;
  public
    constructor Create(aOutput: tOutput; aPluginName: String; aProject: TProject; aConfigPlugin: tConfigPlugin); override;
    destructor Destroy; override;

    function GetTag(aTagName: String; aCodeGeneratorItem: TCodeGeneratorItem): String; override;
    function IsTagExists(aTagName: String): Integer; override;

  end;

  TPlugin_SysTags = class( TSingletonImplementation, INovusPlugin, IExternalPlugin)
  private
  protected
    foProject: TProject;
    FPlugin_SysTags: tPlugin_SysTagsBase;
  public
    function GetPluginName: string; safecall;

    procedure Initialize; safecall;
    procedure Finalize; safecall;

    property PluginName: string read GetPluginName;

    function CreatePlugin(aOutput: tOutput; aProject: Tproject; aConfigPlugin: TConfigPlugin): TPlugin; safecall;

  end;

function GetPluginObject: INovusPlugin; stdcall;

implementation

var
  _Plugin_SysTags: TPlugin_SysTags = nil;

constructor tPlugin_SysTagsBase.Create(aOutput: tOutput; aPluginName: String; aProject: TProject; aConfigPlugin: tConfigPlugin);
begin
  Inherited Create(aOutput,aPluginName, aProject, aConfigPlugin);

  FSysTags:= tSysTags.Create(TSysTag_Version.Create,
                             TSysTag_newguid.Create,
                             TSysTag_NewguidNoBrackets.Create,
                             TSysTag_FilePathToURL.Create) ;
end;


destructor  tPlugin_SysTagsBase.Destroy;
Var
  I: Integer;
begin
  for I := 0 to Length(FSysTags) -1 do
   begin
     FSysTags[i].Free;
     FSysTags[i] := NIL;
   end;

  FSysTags := NIL;
  Inherited;
end;

// Plugin_SysTags
function tPlugin_SysTags.GetPluginName: string;
begin
  Result := 'Sys';
end;

procedure tPlugin_SysTags.Initialize;
begin
end;

function tPlugin_SysTags.CreatePlugin(aOutput: tOutput; aProject: TProject; aConfigPlugin: TConfigPlugin): TPlugin; safecall;
begin
  foProject := aProject;

  FPlugin_SysTags := tPlugin_SysTagsBase.Create(aOutput, GetPluginName, foProject, aConfigPlugin);

  Result := FPlugin_SysTags;
end;


procedure tPlugin_SysTags.Finalize;
begin
  //if Assigned(FPlugin_SysTags) then FPlugin_SysTags.Free;
end;

// tPlugin_SysTagsBase
function tPlugin_SysTagsBase.GetTag(aTagName: String; aCodeGeneratorItem: TCodeGeneratorItem): String;
Var
  liIndex: Integer;
begin
  Result := '';
  liIndex := IsTagExists(aTagName);
  if liIndex = -1 then
   begin
     oOutput.LogError('Cannot find sys.' + aTagname);

     Exit;
   end;
  
  Result := FSysTags[liIndex].Execute(aCodeGeneratorItem);
end;

function tPlugin_SysTagsBase.IsTagExists(aTagName: String): Integer;
Var
  I: Integer;
begin
  Result := -1;
  if aTagName = '' then Exit;
   
  for I := 0 to Length(FSysTags) -1 do
   begin
     if Uppercase(Trim(aTagName)) = Uppercase(Trim(FSysTags[i].TagName)) then
       begin
         Result := i;

         Break;
       end;
   end;
end;


function GetPluginObject: INovusPlugin;
begin
  if (_Plugin_SysTags = nil) then _Plugin_SysTags := TPlugin_SysTags.Create;
  result := _Plugin_SysTags;
end;


function TSysTag.GetTagName: String;
begin
  Result := '';
end;

function TSysTag.Execute(aCodeGeneratorItem: TCodeGeneratorItem): String;
begin
  Result := '';
end;

function TSysTag_Version.GetTagName: String;
begin
  Result := 'VERSION';
end;

function TSysTag_Version.Execute(aCodeGeneratorItem: TCodeGeneratorItem): String;
begin
  result := oRuntime.GetVersion(1);
end;

function TSysTag_FilePathToURL.GetTagName: String;
begin
  Result := 'FILEPATHTOURL';
end;

function TSysTag_FilePathToURL.Execute(aCodeGeneratorItem: TCodeGeneratorItem): String;
begin
  result := 'HHH';
end;


function TSysTag_Newguid.GetTagName: String;
begin
  Result := 'NEWGUID';
end;

function TSysTag_Newguid.Execute(aCodeGeneratorItem: TCodeGeneratorItem): String;
begin
  Result := TGuidExUtils.NewGuidString;
end;

function TSysTag_NewguidNoBrackets.GetTagName: String;
begin
  Result := 'NEWGUIDNOBRACKETS';
end;

function TSysTag_NewguidNoBrackets.Execute(aCodeGeneratorItem: TCodeGeneratorItem): String;
begin
  Result := TGuidExUtils.NewGuidNoBracketsString;;
end;


exports
  GetPluginObject name func_GetPluginObject;

initialization
  begin
    _Plugin_SysTags := nil;
  end;

finalization
  FreeAndNIL(_Plugin_SysTags);

end.


