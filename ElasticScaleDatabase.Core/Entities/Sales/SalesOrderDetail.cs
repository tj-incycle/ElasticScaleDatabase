using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ElasticScaleDatabase.Core.Entities.Sales
{
    [Table("Sales.SalesOrderDetail")]
    public class SalesOrderDetail
    {
        [StringLength(25)]
        public string CarrierTrackingNumber { get; set; }

        [Column(TypeName = "numeric")]
        [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
        public decimal LineTotal { get; set; }

        public DateTime ModifiedDate { get; set; }

        public short OrderQty { get; set; }

        public int ProductID { get; set; }

        public Guid rowguid { get; set; }

        [Key]
        [Column(Order = 1)]
        public int SalesOrderDetailID { get; set; }

        public virtual SalesOrderHeader SalesOrderHeader { get; set; }

        [Key]
        [Column(Order = 0)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int SalesOrderID { get; set; }

        public int SpecialOfferID { get; set; }

        public virtual SpecialOfferProduct SpecialOfferProduct { get; set; }

        [Column(TypeName = "money")]
        public decimal UnitPrice { get; set; }

        [Column(TypeName = "money")]
        public decimal UnitPriceDiscount { get; set; }
    }
}