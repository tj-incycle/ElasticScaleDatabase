using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ElasticScaleDatabase.Core.Entities.Production
{
    [Table("Production.ProductReview")]
    public class ProductReview
    {
        [StringLength(3850)]
        public string Comments { get; set; }

        [Required]
        [StringLength(50)]
        public string EmailAddress { get; set; }

        public DateTime ModifiedDate { get; set; }

        public virtual Product Product { get; set; }

        public int ProductID { get; set; }
        public int ProductReviewID { get; set; }

        public int Rating { get; set; }

        public DateTime ReviewDate { get; set; }

        [Required]
        [StringLength(50)]
        public string ReviewerName { get; set; }
    }
}