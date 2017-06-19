using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ElasticScaleDatabase.WebApi.Models
{
    public class CustomerModel
    {
        public string Name { get; set; }
        public Guid GlobalId { get; set; }
    }
}