using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ElasticScaleDatabase.Core.Entities.Sales
{
    [Table("Sales.SalesTerritoryHistory")]
    public class SalesTerritoryHistory
    {
        [Key]
        [Column(Order = 0)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int BusinessEntityID { get; set; }

        public DateTime? EndDate { get; set; }

        public DateTime ModifiedDate { get; set; }

        public Guid rowguid { get; set; }

        public virtual SalesPerson SalesPerson { get; set; }

        public virtual SalesTerritory SalesTerritory { get; set; }

        [Key]
        [Column(Order = 2)]
        public DateTime StartDate { get; set; }

        [Key]
        [Column(Order = 1)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int TerritoryID { get; set; }
    }
}