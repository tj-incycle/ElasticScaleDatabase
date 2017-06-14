using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ElasticScaleDatabase.Core.Entities.Sales
{
    [Table("Sales.CountryRegionCurrency")]
    public class CountryRegionCurrency
    {
        [Key]
        [Column(Order = 0)]
        [StringLength(3)]
        public string CountryRegionCode { get; set; }

        public virtual Currency Currency { get; set; }

        [Key]
        [Column(Order = 1)]
        [StringLength(3)]
        public string CurrencyCode { get; set; }

        public DateTime ModifiedDate { get; set; }
    }
}