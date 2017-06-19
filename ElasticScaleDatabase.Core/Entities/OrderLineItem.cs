using System.ComponentModel.DataAnnotations.Schema;

namespace ElasticScaleDatabase.Core.Entities
{
    public class OrderLineItem
    {
        public int Id { get; set; }

        public virtual Product Product { get; set; }

        public int ProductId { get; set; }

        public int Quantity { get; set; }

        [Column(TypeName = "money")]
        [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
        public decimal? Total { get; set; }

        [Column(TypeName = "money")]
        public decimal UnitPrice { get; set; }
    }
}