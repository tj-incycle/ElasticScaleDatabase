using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Diagnostics.CodeAnalysis;

namespace ElasticScaleDatabase.Core.Entities.Sales
{
    [Table("Sales.SalesOrderHeader")]
    public class SalesOrderHeader
    {
        [StringLength(15)]
        public string AccountNumber { get; set; }

        public int BillToAddressID { get; set; }

        [StringLength(128)]
        public string Comment { get; set; }

        public virtual CreditCard CreditCard { get; set; }

        [StringLength(15)]
        public string CreditCardApprovalCode { get; set; }

        public int? CreditCardID { get; set; }

        public virtual CurrencyRate CurrencyRate { get; set; }

        public int? CurrencyRateID { get; set; }

        public virtual Customer Customer { get; set; }

        public int CustomerID { get; set; }

        public DateTime DueDate { get; set; }

        [Column(TypeName = "money")]
        public decimal Freight { get; set; }

        public DateTime ModifiedDate { get; set; }

        public bool OnlineOrderFlag { get; set; }

        public DateTime OrderDate { get; set; }

        [StringLength(25)]
        public string PurchaseOrderNumber { get; set; }

        public byte RevisionNumber { get; set; }

        public Guid rowguid { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<SalesOrderDetail> SalesOrderDetails { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<SalesOrderHeaderSalesReason> SalesOrderHeaderSalesReasons { get; set; }

        [Key]
        public int SalesOrderID { get; set; }

        [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
        [Required]
        [StringLength(25)]
        public string SalesOrderNumber { get; set; }

        public virtual SalesPerson SalesPerson { get; set; }

        public int? SalesPersonID { get; set; }

        public virtual SalesTerritory SalesTerritory { get; set; }

        public DateTime? ShipDate { get; set; }

        public int ShipMethodID { get; set; }

        public int ShipToAddressID { get; set; }

        public byte Status { get; set; }

        [Column(TypeName = "money")]
        public decimal SubTotal { get; set; }

        [Column(TypeName = "money")]
        public decimal TaxAmt { get; set; }

        public int? TerritoryID { get; set; }

        [Column(TypeName = "money")]
        [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
        public decimal TotalDue { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public SalesOrderHeader()
        {
            SalesOrderDetails = new HashSet<SalesOrderDetail>();
            SalesOrderHeaderSalesReasons = new HashSet<SalesOrderHeaderSalesReason>();
        }
    }
}