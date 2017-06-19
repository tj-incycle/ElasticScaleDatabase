
create procedure __ShardManagement.spGetAllShardMappingsLocal
@input xml,
@result int output
as
begin
	declare @lsmVersionMajorClient int, 
			@lsmVersionMinorClient int,
			@shardMapId uniqueidentifier,
			@shardId uniqueidentifier,
			@minValue varbinary(128),
			@maxValue varbinary(128)

	select 
		@lsmVersionMajorClient = x.value('(LsmVersion/MajorVersion)[1]', 'int'),
		@lsmVersionMinorClient = x.value('(LsmVersion/MinorVersion)[1]', 'int'),
		@shardMapId = x.value('(ShardMap/Id)[1]', 'uniqueidentifier'),
		@shardId = x.value('(Shard/Id)[1]', 'uniqueidentifier'),
		@minValue = convert(varbinary(128), x.value('(Range[@Null="0"]/MinValue)[1]', 'varchar(258)'), 1),
		@maxValue = convert(varbinary(128), x.value('(Range[@Null="0"]/MaxValue[@Null="0"])[1]', 'varchar(258)'), 1)
	from 
		@input.nodes('/GetAllShardMappingsLocal') as t(x)

	if (@lsmVersionMajorClient is null or @lsmVersionMinorClient is null or @shardMapId is null or @shardId is null)
		goto Error_MissingParameters;

	if (@lsmVersionMajorClient <> __ShardManagement.fnGetStoreVersionMajorLocal())
		goto Error_LSMVersionMismatch;

	declare @mapType int

	select 
		@mapType = MapType
	from
		__ShardManagement.ShardMapsLocal
	where
		ShardMapId = @shardMapId

	if (@mapType is null)
		goto Error_ShardMapNotFound;

	declare @minValueCalculated varbinary(128) = 0x,
			@maxValueCalculated varbinary(128) = null

	if (@minValue is not null)
		set @minValueCalculated = @minValue

	if (@maxValue is not null)
		set @maxValueCalculated = @maxValue

	if (@mapType = 1)
	begin	
		select 
			3, m.MappingId, m.ShardMapId, m.MinValue, m.MaxValue, m.Status, m.LockOwnerId,  -- fields for SqlMapping
			s.ShardId, s.Version, s.ShardMapId, s.Protocol, s.ServerName, s.Port, s.DatabaseName, s.Status -- fields for SqlShard, ShardMapId is repeated here
		from 
			__ShardManagement.ShardMappingsLocal m 
			join 
			__ShardManagement.ShardsLocal s 
			on 
				m.ShardId = s.ShardId
		where
			m.ShardMapId = @shardMapId and 
			m.ShardId = @shardId and 
			MinValue >= @minValueCalculated and 
			((@maxValueCalculated is null) or (MinValue < @maxValueCalculated))
		order by 
			m.MinValue
	end
	else
	begin
		select 
			3, m.MappingId, m.ShardMapId, m.MinValue, m.MaxValue, m.Status, m.LockOwnerId,  -- fields for SqlMapping
			s.ShardId, s.Version, s.ShardMapId, s.Protocol, s.ServerName, s.Port, s.DatabaseName, s.Status -- fields for SqlShard, ShardMapId is repeated here
		from 
			__ShardManagement.ShardMappingsLocal m 
			join 
			__ShardManagement.ShardsLocal s 
			on 
				m.ShardId = s.ShardId
		where
			m.ShardMapId = @shardMapId and 
			m.ShardId = @shardId and 
			((MaxValue is null) or (MaxValue > @minValueCalculated)) and 
			((@maxValueCalculated is null) or (MinValue < @maxValueCalculated))
		order by 
			m.MinValue
	end

	set @result = 1
	goto Exit_Procedure;

Error_ShardMapNotFound:
	set @result = 102
	goto Exit_Procedure;

Error_MissingParameters:
	set @result = 50
	exec __ShardManagement.spGetStoreVersionLocalHelper
	goto Exit_Procedure;

Error_LSMVersionMismatch:
	set @result = 51
	exec __ShardManagement.spGetStoreVersionLocalHelper
	goto Exit_Procedure;

Exit_Procedure:
end