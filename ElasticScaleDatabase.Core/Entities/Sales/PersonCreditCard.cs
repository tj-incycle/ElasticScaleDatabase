using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ElasticScaleDatabase.Core.Entities.Sales
{
    [Table("Sales.PersonCreditCard")]
    public class PersonCreditCard
    {
        [Key]
        [Column(Order = 0)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int BusinessEntityID { get; set; }

        public virtual CreditCard CreditCard { get; set; }

        [Key]
        [Column(Order = 1)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int CreditCardID { get; set; }

        public DateTime ModifiedDate { get; set; }
    }
}