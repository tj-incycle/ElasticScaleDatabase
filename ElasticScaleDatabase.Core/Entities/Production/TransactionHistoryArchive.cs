using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ElasticScaleDatabase.Core.Entities.Production
{
    [Table("Production.TransactionHistoryArchive")]
    public class TransactionHistoryArchive
    {
        [Column(TypeName = "money")]
        public decimal ActualCost { get; set; }

        public DateTime ModifiedDate { get; set; }

        public int ProductID { get; set; }

        public int Quantity { get; set; }

        public int ReferenceOrderID { get; set; }

        public int ReferenceOrderLineID { get; set; }

        public DateTime TransactionDate { get; set; }

        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int TransactionID { get; set; }

        [Required]
        [StringLength(1)]
        public string TransactionType { get; set; }
    }
}