
create procedure __ShardManagement.spKillSessionsForShardMappingLocal
@input xml,
@result int output
as
begin
	declare @lsmVersionMajorClient int,
			@lsmVersionMinorClient int,
			@patternForKill nvarchar(128)

	select 
		@lsmVersionMajorClient = x.value('(LsmVersion/MajorVersion)[1]', 'int'),
		@lsmVersionMinorClient = x.value('(LsmVersion/MinorVersion)[1]', 'int'),
		@patternForKill = x.value('(Pattern)[1]', 'nvarchar(128)')
	from 
		@input.nodes('/KillSessionsForShardMappingLocal') as t(x)

	if (@lsmVersionMajorClient is null or @lsmVersionMinorClient is null or @patternForKill is null)
		goto Error_MissingParameters;

	if (@lsmVersionMajorClient <> __ShardManagement.fnGetStoreVersionMajorLocal())
		goto Error_LSMVersionMismatch;

	declare @tvKillCommands table (spid smallint primary key, commandForKill nvarchar(10))

	insert into 
		@tvKillCommands (spid, commandForKill) 
	values 
		(0, N'')

	insert into 
		@tvKillCommands(spid, commandForKill) 
		select 
			session_id, 'kill ' + convert(nvarchar(10), session_id)
		from 
			sys.dm_exec_sessions 
		where 
			session_id > 50 and program_name like '%' + @patternForKill + '%'

	declare @currentSpid int, 
			@currentCommandForKill nvarchar(10)

	declare @current_error int

	select top 1 
		@currentSpid = spid, 
		@currentCommandForKill = commandForKill 
	from 
		@tvKillCommands 
	order by 
		spid desc

	while (@currentSpid > 0)
	begin
		begin try
			exec (@currentCommandForKill)

			delete 
				@tvKillCommands 
			where 
				spid = @currentSpid

			select top 1 
				@currentSpid = spid, 
				@currentCommandForKill = commandForKill 
			from 
				@tvKillCommands 
			order by 
				spid desc
		end try
		begin catch
			if (error_number() <> 6106)
				goto Error_UnableToKillSessions;
		end catch
	end

	set @result = 1
	goto Exit_Procedure;
	
Error_UnableToKillSessions:
	set @result = 305
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