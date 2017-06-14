using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace ElasticScaleDatabase.Core.Entities.HumanResources
{
    [Table("HumanResources.JobCandidate")]
    public class JobCandidate
    {
        public int? BusinessEntityID { get; set; }

        public virtual Employee Employee { get; set; }
        public int JobCandidateID { get; set; }

        public DateTime ModifiedDate { get; set; }

        [Column(TypeName = "xml")]
        public string Resume { get; set; }
    }
}