unit TokenParser;

interface

uses  ProjectItem, system.Classes, Project, Variables, output, SysUtils, TagType;

type
   tTokenProcessor = class(TStringList)
   private
     fiIndex: Integer;
   protected
   public
     constructor Create; overload;
     function GetNextToken: string;
     function IsNextTokenEquals: boolean;
   end;

   tTokenParser = class(Tobject)
   protected
   private
   public
     class function ParseToken(aObject: TObject; aToken: String;aProjectItem: tProjectItem; aVariables: TVariables; aOutput: Toutput; ATokens: tStringList; Var aIndex: Integer; aProject: TProject): String;

     class function ParseExpressionToken(aObject: TObject;aToken: String; aProjectItem: tProjectItem; aProject: TProject; aVariables: TVariables;aOutput: Toutput): tTokenProcessor; overload;
     class function ParseExpressionToken(aToken: string): tTokenProcessor; overload;
   end;

implementation

uses CodeGenerator, Runtime, Interpreter, Config, ExpressionParser, TagTypeParser;


// Token Processor
constructor tTokenProcessor.Create;
begin
  fiIndex:= 0;
end;

function tTokenProcessor.GetNextToken: String;
begin
  Result := '';

  if fiIndex > Count then  Exit;

  if Count > 0 then
    Result := Trim(Strings[fiIndex]);

  Inc(fiIndex);
end;

function tTokenProcessor.IsNextTokenEquals: boolean;
begin
 Result := GetNextToken = '=';
end;

// TokenParser

class function tTokenParser.ParseExpressionToken(aObject: TObject;aToken: String; aProjectItem: tProjectItem; aProject: TProject; aVariables: TVariables;aOutput: Toutput): tTokenProcessor;
Var
  lEParser: tExpressionParser;
  I: Integer;
  lsNewToken: string;
  FiIndex: Integer;
begin
  Result := NIL;

  if not Assigned(aProject) or Not Assigned(aProjectItem) then Exit;

  Try
    Result := tTokenProcessor.Create;

    lEParser:= tExpressionParser.Create;

    lEParser.Expr := aToken;

    lEParser.ListTokens(Result);

    for I := 0 to Result.Count -1 do
      begin
        FiIndex := 0;
        Result.Strings[i] := ParseToken(aObject,  Result.Strings[i], aProjectItem, aVariables, aOutput, NIL, FiIndex, aProject);
      end;
  Except
    aOutput.InternalError;
  End;
end;

class function tTokenParser.ParseExpressionToken(aToken: string): tTokenProcessor;
Var
  lEParser: tExpressionParser;
  I: Integer;
  lsNewToken: string;
  FiIndex: Integer;
begin
  Result := NIL;

  if Trim(aToken) = '' then Exit;


  Try
    Result := tTokenProcessor.Create;

    lEParser:= tExpressionParser.Create;

    lEParser.Expr := aToken;

    lEParser.ListTokens(Result);

  Except
    //aOutput.InternalError;
  End;
end;


class function tTokenParser.ParseToken;
var
  fsToken: String;
  lEParser: tExpressionParser;
  lTokens: TStringlist;
  lTagType: tTagType;
  lsValue : String;
  loVarable: tVariable;
  lsToken1, lsToken2: string;
  lVariable: TVariable;
begin
  Result := aToken;

  If Copy(aToken, 1, 2) = '$$' then
    begin
      fsToken := Copy(aToken, 3, Length(aToken));

      if aObject is tInterpreter then
        begin
          lsToken1 := fsToken;

          lTagType := TTagTypeParser.ParseTagType(aProjectItem, NIL, lsToken1,'' );
        end
      else
      if aObject is TCodeGenerator then
        begin
          Try
            lTokens := TStringList.Create;

            lEParser:= tExpressionParser.Create;

            lEParser.Expr := fsToken;

            lEParser.ListTokens(lTokens);

            if lTokens.Count > 0 then
              begin
                lsToken1 := Uppercase(lTokens.Strings[0]);
                if lTokens.Count > 1 then
                  lsToken2 := Uppercase(lTokens.Strings[1]);
               end;
           Finally
            lEParser.Free;
            lTokens.Free;
          End;

          lTagType := TTagTypeParser.ParseTagType(aProjectItem, (aObject as TCodeGenerator), lsToken1,lsToken2 );
        end
        else
          lTagType := TTagTypeParser.ParseTagType(aProjectItem, NIL, lsToken1,lsToken2 );

        case lTagType of
          ttProperty: Result := aProjectItem.oProperties.GetProperty(fsToken);
          ttPropertyEx: begin
             if aObject is tInterpreter then
               begin
                 lsToken2 :=  tInterpreter(aObject).GetNextToken(AIndex, ATokens);

               end;

             if lsToken2 <> '' then
               begin
                 Result := aProjectItem.oProperties.GetProperty(lsToken2);
               end;
          end;
          ttprojectitem: begin
                  Result := aProjectItem.GetProperty(lsToken2, aProject);

              end;
          ttplugintag: begin
              if aObject is tInterpreter then
               begin
                 lsToken2 :=  tInterpreter(aObject).GetNextToken(AIndex, ATokens);

               end;


              if oRuntime.oPlugins.IsTagExists(lsToken1, lsToken2) then
                begin
                  Result := oRuntime.oPlugins.GetTag(lsToken1, lsToken2);
                end;
          end;
          ttVariableCmdLine: begin
            lVariable := oConfig.oVariablesCmdLine.GetVariableByName(lsToken2);

            if Assigned(lVariable) then
              Result := lVariable.Value;

          end;

          ttConfigProperties: begin
            result := aProject.oProjectConfig.Getproperties(lsToken2);
          end;

          ttUnknown: begin
             aOutput.LogError('Syntax Error: Tag '+ lsToken1 + ' cannot be found.');

          end;
        end;
      end
   else
   If Copy(aToken, 1, 1) = '$' then
    begin
      lsValue := TVariables.CleanVariableName(aToken);
      if Assigned(aVariables) then
        begin
          loVarable := aVariables.GetVariableByName(lsValue);
          if Not Assigned(loVarable) then
            begin
              aOutput.LogError('Syntax Error: variable '+ lsValue + ' cannot be found.');
            end
          else Result := loVarable.Value;
        end
      else
        begin
          aOutput.LogError('Syntax Error: variable '+ lsValue + ' cannot be found.');
        end;
    end;
end;




end.
