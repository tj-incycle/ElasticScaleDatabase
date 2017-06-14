using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Diagnostics.CodeAnalysis;

namespace ElasticScaleDatabase.Core.Entities.Purchasing
{
    [Table("Purchasing.Vendor")]
    public class Vendor
    {
        [Required]
        [StringLength(15)]
        public string AccountNumber { get; set; }

        public bool ActiveFlag { get; set; }

        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int BusinessEntityID { get; set; }

        public byte CreditRating { get; set; }

        public DateTime ModifiedDate { get; set; }

        [Required]
        [StringLength(50)]
        public string Name { get; set; }

        public bool PreferredVendorStatus { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<ProductVendor> ProductVendors { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<PurchaseOrderHeader> PurchaseOrderHeaders { get; set; }

        [StringLength(1024)]
        public string PurchasingWebServiceURL { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public Vendor()
        {
            ProductVendors = new HashSet<ProductVendor>();
            PurchaseOrderHeaders = new HashSet<PurchaseOrderHeader>();
        }
    }
}