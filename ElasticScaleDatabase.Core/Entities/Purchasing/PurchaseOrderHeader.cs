using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Diagnostics.CodeAnalysis;

namespace ElasticScaleDatabase.Core.Entities.Purchasing
{
    [Table("Purchasing.PurchaseOrderHeader")]
    public class PurchaseOrderHeader
    {
        public int EmployeeID { get; set; }

        [Column(TypeName = "money")]
        public decimal Freight { get; set; }

        public DateTime ModifiedDate { get; set; }

        public DateTime OrderDate { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<PurchaseOrderDetail> PurchaseOrderDetails { get; set; }

        [Key]
        public int PurchaseOrderID { get; set; }

        public byte RevisionNumber { get; set; }

        public DateTime? ShipDate { get; set; }

        public virtual ShipMethod ShipMethod { get; set; }

        public int ShipMethodID { get; set; }

        public byte Status { get; set; }

        [Column(TypeName = "money")]
        public decimal SubTotal { get; set; }

        [Column(TypeName = "money")]
        public decimal TaxAmt { get; set; }

        [Column(TypeName = "money")]
        [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
        public decimal TotalDue { get; set; }

        public virtual Vendor Vendor { get; set; }

        public int VendorID { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public PurchaseOrderHeader()
        {
            PurchaseOrderDetails = new HashSet<PurchaseOrderDetail>();
        }
    }
}