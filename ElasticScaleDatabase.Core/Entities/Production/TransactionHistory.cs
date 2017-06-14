using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ElasticScaleDatabase.Core.Entities.Production
{
    [Table("Production.TransactionHistory")]
    public class TransactionHistory
    {
        [Column(TypeName = "money")]
        public decimal ActualCost { get; set; }

        public DateTime ModifiedDate { get; set; }

        public virtual Product Product { get; set; }

        public int ProductID { get; set; }

        public int Quantity { get; set; }

        public int ReferenceOrderID { get; set; }

        public int ReferenceOrderLineID { get; set; }

        public DateTime TransactionDate { get; set; }

        [Key]
        public int TransactionID { get; set; }

        [Required]
        [StringLength(1)]
        public string TransactionType { get; set; }
    }
}