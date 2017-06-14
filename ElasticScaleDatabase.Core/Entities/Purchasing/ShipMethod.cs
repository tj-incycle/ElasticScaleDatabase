using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Diagnostics.CodeAnalysis;

namespace ElasticScaleDatabase.Core.Entities.Purchasing
{
    [Table("Purchasing.ShipMethod")]
    public class ShipMethod
    {
        public DateTime ModifiedDate { get; set; }

        [Required]
        [StringLength(50)]
        public string Name { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<PurchaseOrderHeader> PurchaseOrderHeaders { get; set; }

        public Guid rowguid { get; set; }

        [Column(TypeName = "money")]
        public decimal ShipBase { get; set; }

        public int ShipMethodID { get; set; }

        [Column(TypeName = "money")]
        public decimal ShipRate { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public ShipMethod()
        {
            PurchaseOrderHeaders = new HashSet<PurchaseOrderHeader>();
        }
    }
}