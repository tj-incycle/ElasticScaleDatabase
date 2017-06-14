using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ElasticScaleDatabase.Core.Entities.Production
{
    [Table("Production.BillOfMaterials")]
    public class BillOfMaterial
    {
        [Key]
        public int BillOfMaterialsID { get; set; }

        public short BOMLevel { get; set; }

        public int ComponentID { get; set; }

        public DateTime? EndDate { get; set; }

        public DateTime ModifiedDate { get; set; }

        public decimal PerAssemblyQty { get; set; }

        public virtual Product Product { get; set; }

        public virtual Product Product1 { get; set; }

        public int? ProductAssemblyID { get; set; }

        public DateTime StartDate { get; set; }

        public virtual UnitMeasure UnitMeasure { get; set; }

        [Required]
        [StringLength(3)]
        public string UnitMeasureCode { get; set; }
    }
}