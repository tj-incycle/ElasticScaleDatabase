using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ElasticScaleDatabase.Core.Entities.People
{
    [Table("Person.Password")]
    public class Password
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int BusinessEntityID { get; set; }

        public DateTime ModifiedDate { get; set; }

        [Required]
        [StringLength(128)]
        public string PasswordHash { get; set; }

        [Required]
        [StringLength(10)]
        public string PasswordSalt { get; set; }

        public virtual Person Person { get; set; }

        public Guid rowguid { get; set; }
    }
}