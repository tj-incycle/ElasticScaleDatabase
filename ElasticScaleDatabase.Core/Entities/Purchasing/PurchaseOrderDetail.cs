using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ElasticScaleDatabase.Core.Entities.Purchasing
{
    [Table("Purchasing.PurchaseOrderDetail")]
    public class PurchaseOrderDetail
    {
        public DateTime DueDate { get; set; }

        [Column(TypeName = "money")]
        [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
        public decimal LineTotal { get; set; }

        public DateTime ModifiedDate { get; set; }

        public short OrderQty { get; set; }

        public int ProductID { get; set; }

        [Key]
        [Column(Order = 1)]
        public int PurchaseOrderDetailID { get; set; }

        public virtual PurchaseOrderHeader PurchaseOrderHeader { get; set; }

        [Key]
        [Column(Order = 0)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int PurchaseOrderID { get; set; }

        public decimal ReceivedQty { get; set; }

        public decimal RejectedQty { get; set; }

        [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
        public decimal StockedQty { get; set; }

        [Column(TypeName = "money")]
        public decimal UnitPrice { get; set; }
    }
}