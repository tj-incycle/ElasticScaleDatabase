using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Diagnostics.CodeAnalysis;

namespace ElasticScaleDatabase.Core.Entities.Production
{
    [Table("Production.ProductPhoto")]
    public class ProductPhoto
    {
        public byte[] LargePhoto { get; set; }

        [StringLength(50)]
        public string LargePhotoFileName { get; set; }

        public DateTime ModifiedDate { get; set; }

        public int ProductPhotoID { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<ProductProductPhoto> ProductProductPhotoes { get; set; }

        public byte[] ThumbNailPhoto { get; set; }

        [StringLength(50)]
        public string ThumbnailPhotoFileName { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public ProductPhoto()
        {
            ProductProductPhotoes = new HashSet<ProductProductPhoto>();
        }
    }
}