using System;

namespace ElasticScaleDatabase.Core.Entities
{
    public class Order
    {
        public int Id { get; set; }

        public int LocationId { get; set; }

        public int OrderedByUserId { get; set; }

        public DateTime OrderedDateTime { get; set; }

        public virtual User User { get; set; }
    }
}