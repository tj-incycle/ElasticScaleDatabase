using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Diagnostics.CodeAnalysis;

namespace ElasticScaleDatabase.Core.Entities.Sales
{
    [Table("Sales.SalesTerritory")]
    public class SalesTerritory
    {
        [Column(TypeName = "money")]
        public decimal CostLastYear { get; set; }

        [Column(TypeName = "money")]
        public decimal CostYTD { get; set; }

        [Required]
        [StringLength(3)]
        public string CountryRegionCode { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Customer> Customers { get; set; }

        [Required]
        [StringLength(50)]
        public string Group { get; set; }

        public DateTime ModifiedDate { get; set; }

        [Required]
        [StringLength(50)]
        public string Name { get; set; }

        public Guid rowguid { get; set; }

        [Column(TypeName = "money")]
        public decimal SalesLastYear { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<SalesOrderHeader> SalesOrderHeaders { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<SalesPerson> SalesPersons { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<SalesTerritoryHistory> SalesTerritoryHistories { get; set; }

        [Column(TypeName = "money")]
        public decimal SalesYTD { get; set; }

        [Key]
        public int TerritoryID { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public SalesTerritory()
        {
            Customers = new HashSet<Customer>();
            SalesOrderHeaders = new HashSet<SalesOrderHeader>();
            SalesPersons = new HashSet<SalesPerson>();
            SalesTerritoryHistories = new HashSet<SalesTerritoryHistory>();
        }
    }
}