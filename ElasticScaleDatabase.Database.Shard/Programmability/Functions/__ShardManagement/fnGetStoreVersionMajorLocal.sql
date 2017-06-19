

create function __ShardManagement.fnGetStoreVersionMajorLocal()
returns int
as
begin
	return (select StoreVersionMajor from __ShardManagement.ShardMapManagerLocal)
end