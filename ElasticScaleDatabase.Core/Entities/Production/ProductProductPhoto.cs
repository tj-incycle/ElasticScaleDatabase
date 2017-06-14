using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ElasticScaleDatabase.Core.Entities.Production
{
    [Table("Production.ProductProductPhoto")]
    public class ProductProductPhoto
    {
        public DateTime ModifiedDate { get; set; }

        public bool Primary { get; set; }

        public virtual Product Product { get; set; }

        [Key]
        [Column(Order = 0)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int ProductID { get; set; }

        public virtual ProductPhoto ProductPhoto { get; set; }

        [Key]
        [Column(Order = 1)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int ProductPhotoID { get; set; }
    }
}