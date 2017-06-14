using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ElasticScaleDatabase.Core.Entities.Production
{
    [Table("Production.ProductModelProductDescriptionCulture")]
    public class ProductModelProductDescriptionCulture
    {
        public virtual Culture Culture { get; set; }

        [Key]
        [Column(Order = 2)]
        [StringLength(6)]
        public string CultureID { get; set; }

        public DateTime ModifiedDate { get; set; }

        public virtual ProductDescription ProductDescription { get; set; }

        [Key]
        [Column(Order = 1)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int ProductDescriptionID { get; set; }

        public virtual ProductModel ProductModel { get; set; }

        [Key]
        [Column(Order = 0)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int ProductModelID { get; set; }
    }
}