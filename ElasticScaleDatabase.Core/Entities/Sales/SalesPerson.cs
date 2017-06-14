using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Diagnostics.CodeAnalysis;

namespace ElasticScaleDatabase.Core.Entities.Sales
{
    [Table("Sales.SalesPerson")]
    public class SalesPerson
    {
        [Column(TypeName = "money")]
        public decimal Bonus { get; set; }

        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int BusinessEntityID { get; set; }

        [Column(TypeName = "smallmoney")]
        public decimal CommissionPct { get; set; }

        public DateTime ModifiedDate { get; set; }

        public Guid rowguid { get; set; }

        [Column(TypeName = "money")]
        public decimal SalesLastYear { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<SalesOrderHeader> SalesOrderHeaders { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<SalesPersonQuotaHistory> SalesPersonQuotaHistories { get; set; }

        [Column(TypeName = "money")]
        public decimal? SalesQuota { get; set; }

        public virtual SalesTerritory SalesTerritory { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<SalesTerritoryHistory> SalesTerritoryHistories { get; set; }

        [Column(TypeName = "money")]
        public decimal SalesYTD { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Store> Stores { get; set; }

        public int? TerritoryID { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public SalesPerson()
        {
            SalesOrderHeaders = new HashSet<SalesOrderHeader>();
            SalesPersonQuotaHistories = new HashSet<SalesPersonQuotaHistory>();
            SalesTerritoryHistories = new HashSet<SalesTerritoryHistory>();
            Stores = new HashSet<Store>();
        }
    }
}