using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.Spatial;
using System.Diagnostics.CodeAnalysis;

namespace ElasticScaleDatabase.Core.Entities.People
{
    [Table("Person.Address")]
    public class Address
    {
        public int AddressID { get; set; }

        [Required]
        [StringLength(60)]
        public string AddressLine1 { get; set; }

        [StringLength(60)]
        public string AddressLine2 { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<BusinessEntityAddress> BusinessEntityAddresses { get; set; }

        [Required]
        [StringLength(30)]
        public string City { get; set; }

        public DateTime ModifiedDate { get; set; }

        [Required]
        [StringLength(15)]
        public string PostalCode { get; set; }

        public Guid rowguid { get; set; }

        public DbGeography SpatialLocation { get; set; }

        public virtual StateProvince StateProvince { get; set; }

        public int StateProvinceID { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public Address()
        {
            BusinessEntityAddresses = new HashSet<BusinessEntityAddress>();
        }
    }
}