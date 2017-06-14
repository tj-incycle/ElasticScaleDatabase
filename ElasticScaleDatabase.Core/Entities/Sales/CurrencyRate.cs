using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Diagnostics.CodeAnalysis;

namespace ElasticScaleDatabase.Core.Entities.Sales
{
    [Table("Sales.CurrencyRate")]
    public class CurrencyRate
    {
        [Column(TypeName = "money")]
        public decimal AverageRate { get; set; }

        public virtual Currency Currency { get; set; }

        public virtual Currency Currency1 { get; set; }

        public DateTime CurrencyRateDate { get; set; }

        public int CurrencyRateID { get; set; }

        [Column(TypeName = "money")]
        public decimal EndOfDayRate { get; set; }

        [Required]
        [StringLength(3)]
        public string FromCurrencyCode { get; set; }

        public DateTime ModifiedDate { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<SalesOrderHeader> SalesOrderHeaders { get; set; }

        [Required]
        [StringLength(3)]
        public string ToCurrencyCode { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public CurrencyRate()
        {
            SalesOrderHeaders = new HashSet<SalesOrderHeader>();
        }
    }
}