using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ElasticScaleDatabase.Core.Entities.Sales
{
    [Table("Sales.ShoppingCartItem")]
    public class ShoppingCartItem
    {
        public DateTime DateCreated { get; set; }

        public DateTime ModifiedDate { get; set; }

        public int ProductID { get; set; }

        public int Quantity { get; set; }

        [Required]
        [StringLength(50)]
        public string ShoppingCartID { get; set; }

        public int ShoppingCartItemID { get; set; }
    }
}