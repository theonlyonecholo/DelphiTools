unit ToJSON;

interface

uses
  System.Classes,
  System.SysUtils,
  Winapi.Windows,
  System.Json,
  System.Rtti;

type
  TToJson = class (TObject)
  public
  class procedure ToJson(IN_Class : TObject; var IO_Json : TJSONObject);
  end;

implementation

{ TToJson }

class procedure TToJson.ToJson(IN_Class: TObject; var IO_Json: TJSONObject);
var
  Context  : TRttiContext;
  ObjType  : TRttiType;
  Prop     : TRttiProperty;
  i        : integer;
  JSONArr  : TJSONArray;
  JSONObj  : TJSONObject;
  JSONPair : TJSONPair;
begin
  Context := TRttiContext.Create;
  ObjType := Context.GetType(IN_Class.ClassInfo) as TRttiInstanceType;
  for Prop in ObjType.GetProperties do
  begin
    if Prop.IsReadable then
      case Prop.PropertyType.TypeKind of
        tkInteger :
          begin
            IO_Json.AddPair(Prop.Name, TJSONNumber.Create(Prop.GetValue(IN_Class).AsInteger()))
          end;
        tkFloat :
          begin
            IO_Json.AddPair(Prop.Name, TJSONNumber.Create(Prop.GetValue(IN_Class).AsExtended()))
          end;
        tkUString, tkString, tkChar :
          begin
            IO_Json.AddPair(Prop.Name, Prop.GetValue(IN_Class).AsString())
          end;
        tkVariant :
          begin
            IO_Json.AddPair(Prop.Name, TJSONNumber.Create(Prop.GetValue(IN_Class).AsVariant()))
          end;
        tkDynArray :
          begin
            JSONArr  := TJSONArray.Create();
            JSONPair := TJSONPair.Create(Prop.Name, JSONArr);
            IO_Json.AddPair(JSONPair);
            for i := 0 to Prop.GetValue(IN_Class).GetArrayLength -1 do
            begin
              JSONObj  := TJSONObject.Create();
              ToJson(Prop.GetValue(IN_Class).GetArrayElement(i).AsObject, JSONObj);
              JSONArr.AddElement(JSONObj);
            end;
          end;
        tkClass :
          begin
            JSONObj  := TJSONObject.Create();
            JSONPair := TJSONPair.Create(Prop.Name, JSONObj);
            IO_Json.AddPair(JSONPair);
            ToJson(Prop.GetValue(IN_Class).AsObject, JSONObj);
          end;
      end;
  end;
end;

end.
