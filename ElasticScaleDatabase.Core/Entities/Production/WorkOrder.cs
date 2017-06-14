using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Diagnostics.CodeAnalysis;

namespace ElasticScaleDatabase.Core.Entities.Production
{
    [Table("Production.WorkOrder")]
    public class WorkOrder
    {
        public DateTime DueDate { get; set; }

        public DateTime? EndDate { get; set; }

        public DateTime ModifiedDate { get; set; }

        public int OrderQty { get; set; }

        public virtual Product Product { get; set; }

        public int ProductID { get; set; }

        public short ScrappedQty { get; set; }

        public virtual ScrapReason ScrapReason { get; set; }

        public short? ScrapReasonID { get; set; }

        public DateTime StartDate { get; set; }

        [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
        public int StockedQty { get; set; }

        public int WorkOrderID { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<WorkOrderRouting> WorkOrderRoutings { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public WorkOrder()
        {
            WorkOrderRoutings = new HashSet<WorkOrderRouting>();
        }
    }
}