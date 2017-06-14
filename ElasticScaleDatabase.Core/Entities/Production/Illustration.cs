using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Diagnostics.CodeAnalysis;

namespace ElasticScaleDatabase.Core.Entities.Production
{
    [Table("Production.Illustration")]
    public class Illustration
    {
        [Column(TypeName = "xml")]
        public string Diagram { get; set; }

        public int IllustrationID { get; set; }

        public DateTime ModifiedDate { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<ProductModelIllustration> ProductModelIllustrations { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public Illustration()
        {
            ProductModelIllustrations = new HashSet<ProductModelIllustration>();
        }
    }
}