using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ElasticScaleDatabase.Core.Entities.Sales
{
    [Table("Sales.SalesOrderHeaderSalesReason")]
    public class SalesOrderHeaderSalesReason
    {
        public DateTime ModifiedDate { get; set; }

        public virtual SalesOrderHeader SalesOrderHeader { get; set; }

        [Key]
        [Column(Order = 0)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int SalesOrderID { get; set; }

        public virtual SalesReason SalesReason { get; set; }

        [Key]
        [Column(Order = 1)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int SalesReasonID { get; set; }
    }
}