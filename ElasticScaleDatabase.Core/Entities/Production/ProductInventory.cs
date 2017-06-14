using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ElasticScaleDatabase.Core.Entities.Production
{
    [Table("Production.ProductInventory")]
    public class ProductInventory
    {
        public byte Bin { get; set; }

        public virtual Location Location { get; set; }

        [Key]
        [Column(Order = 1)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public short LocationID { get; set; }

        public DateTime ModifiedDate { get; set; }

        public virtual Product Product { get; set; }

        [Key]
        [Column(Order = 0)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int ProductID { get; set; }

        public short Quantity { get; set; }

        public Guid rowguid { get; set; }

        [Required]
        [StringLength(10)]
        public string Shelf { get; set; }
    }
}