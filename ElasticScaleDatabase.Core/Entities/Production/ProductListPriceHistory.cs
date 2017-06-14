using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ElasticScaleDatabase.Core.Entities.Production
{
    [Table("Production.ProductListPriceHistory")]
    public class ProductListPriceHistory
    {
        public DateTime? EndDate { get; set; }

        [Column(TypeName = "money")]
        public decimal ListPrice { get; set; }

        public DateTime ModifiedDate { get; set; }

        public virtual Product Product { get; set; }

        [Key]
        [Column(Order = 0)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int ProductID { get; set; }

        [Key]
        [Column(Order = 1)]
        public DateTime StartDate { get; set; }
    }
}