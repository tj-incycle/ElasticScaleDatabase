

create function __ShardManagement.fnGetStoreVersionMajorGlobal()
returns int
as
begin
	return (select StoreVersionMajor from __ShardManagement.ShardMapManagerGlobal)
end