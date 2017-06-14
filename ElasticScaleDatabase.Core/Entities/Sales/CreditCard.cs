using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Diagnostics.CodeAnalysis;

namespace ElasticScaleDatabase.Core.Entities.Sales
{
    [Table("Sales.CreditCard")]
    public class CreditCard
    {
        [Required]
        [StringLength(25)]
        public string CardNumber { get; set; }

        [Required]
        [StringLength(50)]
        public string CardType { get; set; }

        public int CreditCardID { get; set; }

        public byte ExpMonth { get; set; }

        public short ExpYear { get; set; }

        public DateTime ModifiedDate { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<PersonCreditCard> PersonCreditCards { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<SalesOrderHeader> SalesOrderHeaders { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public CreditCard()
        {
            PersonCreditCards = new HashSet<PersonCreditCard>();
            SalesOrderHeaders = new HashSet<SalesOrderHeader>();
        }
    }
}