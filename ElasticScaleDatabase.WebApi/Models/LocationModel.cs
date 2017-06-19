using System.Runtime.Serialization;
using ElasticScaleDatabase.Core.Entities;

namespace ElasticScaleDatabase.WebApi.Models
{
    [DataContract]
    public class LocationModel
    {
        [DataMember]
        public string Address { get; set; }

        [DataMember]
        public string City { get; set; }

        [DataMember]
        public int Id { get; set; }

        [DataMember]
        public string Name { get; set; }

        [DataMember]
        public string PhoneNumber { get; set; }

        [DataMember]
        public string State { get; set; }

        [DataMember]
        public string ZipCode { get; set; }

        public static LocationModel ConvertTo(Location location)
        {
            return new LocationModel
            {
                Address = location.Address,
                City = location.City,
                Id = location.Id,
                Name = location.Name,
                PhoneNumber = location.PhoneNumber,
                State = location.State,
                ZipCode = location.ZipCode
            };
        }
    }
}