using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ElasticScaleDatabase.Core.Entities.HumanResources
{
    [Table("HumanResources.EmployeeDepartmentHistory")]
    public class EmployeeDepartmentHistory
    {
        [Key]
        [Column(Order = 0)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int BusinessEntityID { get; set; }

        public virtual Department Department { get; set; }

        [Key]
        [Column(Order = 1)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public short DepartmentID { get; set; }

        public virtual Employee Employee { get; set; }

        [Column(TypeName = "date")]
        public DateTime? EndDate { get; set; }

        public DateTime ModifiedDate { get; set; }

        public virtual Shift Shift { get; set; }

        [Key]
        [Column(Order = 2)]
        public byte ShiftID { get; set; }

        [Key]
        [Column(Order = 3, TypeName = "date")]
        public DateTime StartDate { get; set; }
    }
}