using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ElasticScaleDatabase.Core.Entities.People
{
    [Table("Person.BusinessEntityContact")]
    public class BusinessEntityContact
    {
        public virtual BusinessEntity BusinessEntity { get; set; }

        [Key]
        [Column(Order = 0)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int BusinessEntityID { get; set; }

        public virtual ContactType ContactType { get; set; }

        [Key]
        [Column(Order = 2)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int ContactTypeID { get; set; }

        public DateTime ModifiedDate { get; set; }

        public virtual Person Person { get; set; }

        [Key]
        [Column(Order = 1)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int PersonID { get; set; }

        public Guid rowguid { get; set; }
    }
}