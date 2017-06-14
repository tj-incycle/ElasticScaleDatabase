using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ElasticScaleDatabase.Core.Entities.Purchasing
{
    [Table("Purchasing.ProductVendor")]
    public class ProductVendor
    {
        public int AverageLeadTime { get; set; }

        [Key]
        [Column(Order = 1)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int BusinessEntityID { get; set; }

        [Column(TypeName = "money")]
        public decimal? LastReceiptCost { get; set; }

        public DateTime? LastReceiptDate { get; set; }

        public int MaxOrderQty { get; set; }

        public int MinOrderQty { get; set; }

        public DateTime ModifiedDate { get; set; }

        public int? OnOrderQty { get; set; }

        [Key]
        [Column(Order = 0)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int ProductID { get; set; }

        [Column(TypeName = "money")]
        public decimal StandardPrice { get; set; }

        [Required]
        [StringLength(3)]
        public string UnitMeasureCode { get; set; }

        public virtual Vendor Vendor { get; set; }
    }
}