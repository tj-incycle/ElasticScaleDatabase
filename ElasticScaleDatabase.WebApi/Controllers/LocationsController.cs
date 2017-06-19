using System;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using ElasticScaleDatabase.Core.Entities;
using ElasticScaleDatabase.WebApi.Models;

namespace ElasticScaleDatabase.WebApi.Controllers
{
    public class LocationsController : WebApiController
    {
        [Route("api/{customerId}/locations")]
        [HttpGet]
        public HttpResponseMessage Get(Guid customerId)
        {
            try
            {
                using (var context = new OrdersContext(customerId))
                {
                    var locations = context.Locations.ToList().Select(LocationModel.ConvertTo).ToList();

                    return locations.Count == 0
                        ? Request.CreateErrorResponse(HttpStatusCode.Found, "Unable to locate any locations for the specified customer.")
                        : Request.CreateResponse(HttpStatusCode.OK, locations);
                }
            }
            catch (Exception exception)
            {
                LogError(Request.RequestUri.AbsolutePath, Request.Method.Method, exception.Message);
                return Request.CreateErrorResponse(HttpStatusCode.InternalServerError, "Unable to retrieve categories at this time.");
            }
        }
    }
}