using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Diagnostics.CodeAnalysis;

namespace ElasticScaleDatabase.Core.Entities.People
{
    [Table("Person.Person")]
    public class Person
    {
        [Column(TypeName = "xml")]
        public string AdditionalContactInfo { get; set; }

        public virtual BusinessEntity BusinessEntity { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<BusinessEntityContact> BusinessEntityContacts { get; set; }

        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int BusinessEntityID { get; set; }

        [Column(TypeName = "xml")]
        public string Demographics { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<EmailAddress> EmailAddresses { get; set; }

        public int EmailPromotion { get; set; }

        [Required]
        [StringLength(50)]
        public string FirstName { get; set; }

        [Required]
        [StringLength(50)]
        public string LastName { get; set; }

        [StringLength(50)]
        public string MiddleName { get; set; }

        public DateTime ModifiedDate { get; set; }

        public bool NameStyle { get; set; }

        public virtual Password Password { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<PersonPhone> PersonPhones { get; set; }

        [Required]
        [StringLength(2)]
        public string PersonType { get; set; }

        public Guid rowguid { get; set; }

        [StringLength(10)]
        public string Suffix { get; set; }

        [StringLength(8)]
        public string Title { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public Person()
        {
            BusinessEntityContacts = new HashSet<BusinessEntityContact>();
            EmailAddresses = new HashSet<EmailAddress>();
            PersonPhones = new HashSet<PersonPhone>();
        }
    }
}