using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Diagnostics.CodeAnalysis;

namespace ElasticScaleDatabase.Core.Entities.Sales
{
    [Table("Sales.SpecialOffer")]
    public class SpecialOffer
    {
        [Required]
        [StringLength(50)]
        public string Category { get; set; }

        [Required]
        [StringLength(255)]
        public string Description { get; set; }

        [Column(TypeName = "smallmoney")]
        public decimal DiscountPct { get; set; }

        public DateTime EndDate { get; set; }

        public int? MaxQty { get; set; }

        public int MinQty { get; set; }

        public DateTime ModifiedDate { get; set; }

        public Guid rowguid { get; set; }

        public int SpecialOfferID { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<SpecialOfferProduct> SpecialOfferProducts { get; set; }

        public DateTime StartDate { get; set; }

        [Required]
        [StringLength(50)]
        public string Type { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public SpecialOffer()
        {
            SpecialOfferProducts = new HashSet<SpecialOfferProduct>();
        }
    }
}