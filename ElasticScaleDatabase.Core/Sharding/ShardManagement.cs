using System;
using System.Configuration;
using System.Data.Common;
using System.Data.SqlClient;
using Microsoft.Azure.SqlDatabase.ElasticScale.ShardManagement;

namespace ElasticScaleDatabase.Core.Sharding
{
    public sealed class ShardManagement
    {
        private static volatile ShardManagement _instance;
        private static readonly object SyncRootObject = new object();

        private readonly ShardMapManager _shardMapManager;
        private readonly ListShardMap<Guid> _shardMap;

        private readonly SqlConnectionStringBuilder _baseShardConnectionStringBuilder;

        public string DatabaseName { get; }

        public string ServerName { get; }

        public static ShardManagement ShardManager
        {
            get
            {
                if (_instance == null)
                    lock (SyncRootObject)
                    {
                        if (_instance == null)
                            _instance = new ShardManagement();
                    }

                return _instance;
            }
        }

        public string ShardMapName { get; }

        private ShardManagement()
        {
            DatabaseName = ConfigurationManager.AppSettings["DatabaseName"];
            ServerName = ConfigurationManager.AppSettings["ServerName"];
            ShardMapName = ConfigurationManager.AppSettings["ShardMapName"];

            _baseShardConnectionStringBuilder = new SqlConnectionStringBuilder
            {
                ApplicationName = ConfigurationManager.AppSettings["ApplicationName"],
                Password = ConfigurationManager.AppSettings["Password"],
                UserID = ConfigurationManager.AppSettings["UserName"]
            };

            bool shardMapDatabaseExists = ShardMapManagerFactory.TryGetSqlShardMapManager(
                GetShardMapManagerConnectionString(),
                ShardMapManagerLoadPolicy.Lazy,
                out _shardMapManager);

            if (!shardMapDatabaseExists)
            {
                _shardMapManager = ShardMapManagerFactory.CreateSqlShardMapManager(GetShardMapManagerConnectionString(), ShardMapManagerCreateMode.ReplaceExisting);
            }

            bool listShardMapExists = _shardMapManager.TryGetListShardMap(ShardMapName, out _shardMap);

            if (!listShardMapExists)
            {
                _shardMap = _shardMapManager.CreateListShardMap<Guid>(ShardMapName);
            }
        }

        public DbConnection GetShardDbConnection(Guid customerId)
        {
            return _shardMap.OpenConnectionForKey(customerId, _baseShardConnectionStringBuilder.ConnectionString);
        }

        private string GetShardMapManagerConnectionString()
        {
            return new SqlConnectionStringBuilder
            {
                ApplicationName = _baseShardConnectionStringBuilder.ApplicationName,
                DataSource = ServerName,
                InitialCatalog = DatabaseName,
                Password = _baseShardConnectionStringBuilder.Password,
                UserID = _baseShardConnectionStringBuilder.UserID,
            }.ConnectionString;
        }

        public void RegisterShard(Guid customerId, string customerName)
        {
            Shard shard;

            var shardLocation = new ShardLocation(ServerName, $"ElasticScaleDatabase_Shard_{customerId:D}");

            if (!_shardMap.TryGetShard(shardLocation, out shard))
            {
                shard = _shardMap.CreateShard(shardLocation);
            }

            PointMapping<Guid> pointMapping;

            if (!_shardMap.TryGetMappingForKey(customerId, out pointMapping))
            {
                _shardMap.CreatePointMapping(customerId, shard);
            }

            using (var sqlConnection = new SqlConnection(GetShardMapManagerConnectionString()))
            using (var sqlCommand = new SqlCommand("INSERT INTO dbo.Customers (Name, GlobalId) VALUES (@name, @globalId)", sqlConnection))
            {
                sqlCommand.Parameters.AddWithValue("name", customerName);
                sqlCommand.Parameters.AddWithValue("globalId", customerId);

                sqlConnection.Open();
                sqlCommand.ExecuteNonQuery();
                sqlConnection.Close();
            }
        }
    }
}