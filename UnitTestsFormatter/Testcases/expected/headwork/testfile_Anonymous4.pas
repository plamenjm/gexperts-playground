unit testfile_Anonymous3;

interface

implementation

procedure SomeProc;
begin
  Comparer := TDelegatedComparer<TData>.Create(
    function(const Data1, Data2: TData): Integer
    begin

    end);
end;

end.