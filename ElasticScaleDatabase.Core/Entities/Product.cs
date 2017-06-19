using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Diagnostics.CodeAnalysis;

namespace ElasticScaleDatabase.Core.Entities
{
    public class Product
    {
        public int Id { get; set; }

        [Required]
        [StringLength(1000)]
        public string Identifier { get; set; }

        [Column(TypeName = "money")]
        public decimal ListPrice { get; set; }

        [Column(TypeName = "money")]
        [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
        public decimal? Markup { get; set; }

        [Required]
        [StringLength(1000)]
        public string Name { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<OrderLineItem> OrderLineItems { get; set; }

        [Column(TypeName = "money")]
        public decimal SalePrice { get; set; }

        public bool Taxable { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public Product()
        {
            OrderLineItems = new HashSet<OrderLineItem>();
        }
    }
}