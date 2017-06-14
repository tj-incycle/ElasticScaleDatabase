using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Diagnostics.CodeAnalysis;

namespace ElasticScaleDatabase.Core.Entities.HumanResources
{
    [Table("HumanResources.Employee")]
    public class Employee
    {
        [Column(TypeName = "date")]
        public DateTime BirthDate { get; set; }

        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int BusinessEntityID { get; set; }

        public bool CurrentFlag { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<EmployeeDepartmentHistory> EmployeeDepartmentHistories { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<EmployeePayHistory> EmployeePayHistories { get; set; }

        [Required]
        [StringLength(1)]
        public string Gender { get; set; }

        [Column(TypeName = "date")]
        public DateTime HireDate { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<JobCandidate> JobCandidates { get; set; }

        [Required]
        [StringLength(50)]
        public string JobTitle { get; set; }

        [Required]
        [StringLength(256)]
        public string LoginID { get; set; }

        [Required]
        [StringLength(1)]
        public string MaritalStatus { get; set; }

        public DateTime ModifiedDate { get; set; }

        [Required]
        [StringLength(15)]
        public string NationalIDNumber { get; set; }

        [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
        public short? OrganizationLevel { get; set; }

        public Guid rowguid { get; set; }

        public bool SalariedFlag { get; set; }

        public short SickLeaveHours { get; set; }

        public short VacationHours { get; set; }

        [SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public Employee()
        {
            EmployeeDepartmentHistories = new HashSet<EmployeeDepartmentHistory>();
            EmployeePayHistories = new HashSet<EmployeePayHistory>();
            JobCandidates = new HashSet<JobCandidate>();
        }
    }
}