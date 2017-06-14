using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Diagnostics.CodeAnalysis;

namespace ElasticScaleDatabase.Core.Entities.Production
{
    [Table("Production.Product")]
    public class Product
    {
        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<BillOfMaterial> BillOfMaterials { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<BillOfMaterial> BillOfMaterials1 { get; set; }

        [StringLength(2)]
        public string Class { get; set; }

        [StringLength(15)]
        public string Color { get; set; }

        public int DaysToManufacture { get; set; }

        public DateTime? DiscontinuedDate { get; set; }

        public bool FinishedGoodsFlag { get; set; }

        [Column(TypeName = "money")]
        public decimal ListPrice { get; set; }

        public bool MakeFlag { get; set; }

        public DateTime ModifiedDate { get; set; }

        [Required]
        [StringLength(50)]
        public string Name { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<ProductCostHistory> ProductCostHistories { get; set; }

        public virtual ProductDocument ProductDocument { get; set; }

        public int ProductID { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<ProductInventory> ProductInventories { get; set; }

        [StringLength(2)]
        public string ProductLine { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<ProductListPriceHistory> ProductListPriceHistories { get; set; }

        public virtual ProductModel ProductModel { get; set; }

        public int? ProductModelID { get; set; }

        [Required]
        [StringLength(25)]
        public string ProductNumber { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<ProductProductPhoto> ProductProductPhotoes { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<ProductReview> ProductReviews { get; set; }

        public virtual ProductSubcategory ProductSubcategory { get; set; }

        public int? ProductSubcategoryID { get; set; }

        public short ReorderPoint { get; set; }

        public Guid rowguid { get; set; }

        public short SafetyStockLevel { get; set; }

        public DateTime? SellEndDate { get; set; }

        public DateTime SellStartDate { get; set; }

        [StringLength(5)]
        public string Size { get; set; }

        [StringLength(3)]
        public string SizeUnitMeasureCode { get; set; }

        [Column(TypeName = "money")]
        public decimal StandardCost { get; set; }

        [StringLength(2)]
        public string Style { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<TransactionHistory> TransactionHistories { get; set; }

        public virtual UnitMeasure UnitMeasure { get; set; }

        public virtual UnitMeasure UnitMeasure1 { get; set; }

        public decimal? Weight { get; set; }

        [StringLength(3)]
        public string WeightUnitMeasureCode { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<WorkOrder> WorkOrders { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public Product()
        {
            BillOfMaterials = new HashSet<BillOfMaterial>();
            BillOfMaterials1 = new HashSet<BillOfMaterial>();
            ProductCostHistories = new HashSet<ProductCostHistory>();
            ProductInventories = new HashSet<ProductInventory>();
            ProductListPriceHistories = new HashSet<ProductListPriceHistory>();
            ProductProductPhotoes = new HashSet<ProductProductPhoto>();
            ProductReviews = new HashSet<ProductReview>();
            TransactionHistories = new HashSet<TransactionHistory>();
            WorkOrders = new HashSet<WorkOrder>();
        }
    }
}