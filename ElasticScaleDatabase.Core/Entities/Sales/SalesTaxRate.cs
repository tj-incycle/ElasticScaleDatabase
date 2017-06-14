using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ElasticScaleDatabase.Core.Entities.Sales
{
    [Table("Sales.SalesTaxRate")]
    public class SalesTaxRate
    {
        public DateTime ModifiedDate { get; set; }

        [Required]
        [StringLength(50)]
        public string Name { get; set; }

        public Guid rowguid { get; set; }
        public int SalesTaxRateID { get; set; }

        public int StateProvinceID { get; set; }

        [Column(TypeName = "smallmoney")]
        public decimal TaxRate { get; set; }

        public byte TaxType { get; set; }
    }
}