using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ElasticScaleDatabase.Core.Entities.People
{
    [Table("Person.PersonPhone")]
    public class PersonPhone
    {
        [Key]
        [Column(Order = 0)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int BusinessEntityID { get; set; }

        public DateTime ModifiedDate { get; set; }

        public virtual Person Person { get; set; }

        [Key]
        [Column(Order = 1)]
        [StringLength(25)]
        public string PhoneNumber { get; set; }

        public virtual PhoneNumberType PhoneNumberType { get; set; }

        [Key]
        [Column(Order = 2)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int PhoneNumberTypeID { get; set; }
    }
}