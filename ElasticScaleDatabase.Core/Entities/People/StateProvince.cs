using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Diagnostics.CodeAnalysis;

namespace ElasticScaleDatabase.Core.Entities.People
{
    [Table("Person.StateProvince")]
    public class StateProvince
    {
        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Address> Addresses { get; set; }

        public virtual CountryRegion CountryRegion { get; set; }

        [Required]
        [StringLength(3)]
        public string CountryRegionCode { get; set; }

        public bool IsOnlyStateProvinceFlag { get; set; }

        public DateTime ModifiedDate { get; set; }

        [Required]
        [StringLength(50)]
        public string Name { get; set; }

        public Guid rowguid { get; set; }

        [Required]
        [StringLength(3)]
        public string StateProvinceCode { get; set; }

        public int StateProvinceID { get; set; }

        public int TerritoryID { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public StateProvince()
        {
            Addresses = new HashSet<Address>();
        }
    }
}