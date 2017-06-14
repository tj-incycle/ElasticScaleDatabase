using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Diagnostics.CodeAnalysis;

namespace ElasticScaleDatabase.Core.Entities.Sales
{
    [Table("Sales.Customer")]
    public class Customer
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
        [Required]
        [StringLength(10)]
        public string AccountNumber { get; set; }

        public int CustomerID { get; set; }

        public DateTime ModifiedDate { get; set; }

        public int? PersonID { get; set; }

        public Guid rowguid { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<SalesOrderHeader> SalesOrderHeaders { get; set; }

        public virtual SalesTerritory SalesTerritory { get; set; }

        public virtual Store Store { get; set; }

        public int? StoreID { get; set; }

        public int? TerritoryID { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public Customer()
        {
            SalesOrderHeaders = new HashSet<SalesOrderHeader>();
        }
    }
}