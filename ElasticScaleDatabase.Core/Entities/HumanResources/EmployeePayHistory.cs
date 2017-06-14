using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ElasticScaleDatabase.Core.Entities.HumanResources
{
    [Table("HumanResources.EmployeePayHistory")]
    public class EmployeePayHistory
    {
        [Key]
        [Column(Order = 0)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int BusinessEntityID { get; set; }

        public virtual Employee Employee { get; set; }

        public DateTime ModifiedDate { get; set; }

        public byte PayFrequency { get; set; }

        [Column(TypeName = "money")]
        public decimal Rate { get; set; }

        [Key]
        [Column(Order = 1)]
        public DateTime RateChangeDate { get; set; }
    }
}