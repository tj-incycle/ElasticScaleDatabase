using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ElasticScaleDatabase.Core.Entities.People
{
    [Table("Person.BusinessEntityAddress")]
    public class BusinessEntityAddress
    {
        public virtual Address Address { get; set; }

        [Key]
        [Column(Order = 1)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int AddressID { get; set; }

        public virtual AddressType AddressType { get; set; }

        [Key]
        [Column(Order = 2)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int AddressTypeID { get; set; }

        public virtual BusinessEntity BusinessEntity { get; set; }

        [Key]
        [Column(Order = 0)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int BusinessEntityID { get; set; }

        public DateTime ModifiedDate { get; set; }

        public Guid rowguid { get; set; }
    }
}