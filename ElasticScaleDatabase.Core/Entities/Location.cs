using System.ComponentModel.DataAnnotations;

namespace ElasticScaleDatabase.Core.Entities
{
    public class Location
    {
        [Required]
        [StringLength(2000)]
        public string Address { get; set; }

        [Required]
        [StringLength(100)]
        public string City { get; set; }

        public int Id { get; set; }

        [Required]
        [StringLength(1000)]
        public string Name { get; set; }

        [Required]
        [StringLength(10)]
        public string PhoneNumber { get; set; }

        [Required]
        [StringLength(2)]
        public string State { get; set; }

        [Required]
        [StringLength(9)]
        public string ZipCode { get; set; }
    }
}