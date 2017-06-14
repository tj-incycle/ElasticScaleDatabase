
create procedure __ShardManagement.spGetStoreVersionGlobalHelper
as
begin
	select
		5, StoreVersionMajor, StoreVersionMinor
	from 
		__ShardManagement.ShardMapManagerGlobal
end