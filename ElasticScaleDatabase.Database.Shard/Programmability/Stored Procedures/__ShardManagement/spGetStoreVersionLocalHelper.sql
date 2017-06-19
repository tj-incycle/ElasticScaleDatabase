
create procedure __ShardManagement.spGetStoreVersionLocalHelper
as
begin
	select
		5, StoreVersionMajor, StoreVersionMinor
	from 
		__ShardManagement.ShardMapManagerLocal
end