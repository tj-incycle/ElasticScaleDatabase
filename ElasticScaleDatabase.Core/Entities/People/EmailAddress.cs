using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ElasticScaleDatabase.Core.Entities.People
{
    [Table("Person.EmailAddress")]
    public class EmailAddress
    {
        [Key]
        [Column(Order = 0)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int BusinessEntityID { get; set; }

        [Column("EmailAddress")]
        [StringLength(50)]
        public string EmailAddress1 { get; set; }

        [Key]
        [Column(Order = 1)]
        public int EmailAddressID { get; set; }

        public DateTime ModifiedDate { get; set; }

        public virtual Person Person { get; set; }

        public Guid rowguid { get; set; }
    }
}