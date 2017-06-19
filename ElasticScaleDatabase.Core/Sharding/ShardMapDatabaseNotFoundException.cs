using System;

namespace ElasticScaleDatabase.Core.Sharding
{
    public class ShardMapDatabaseNotFoundException : Exception
    {
        public ShardMapDatabaseNotFoundException(string databaseName, string serverName)
            : base($"The shard map database '{databaseName}' on the server '{serverName}' could not be located.")
        {
        }
    }
}