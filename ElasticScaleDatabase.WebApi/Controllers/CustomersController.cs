using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web;
using System.Web.Http;
using ElasticScaleDatabase.Core.Entities;
using ElasticScaleDatabase.Core.Sharding;
using ElasticScaleDatabase.WebApi.Models;

namespace ElasticScaleDatabase.WebApi.Controllers
{
    public class CustomersController : WebApiController
    {
        [Route("api/customers/register")]
        [HttpPost]
        public HttpResponseMessage Register([FromBody] CustomerModel customerModel)
        {
            try
            {
                //TODO: Deploy database
                ShardManagement.ShardManager.RegisterShard(customerModel.GlobalId, customerModel.Name);

                return Request.CreateResponse(HttpStatusCode.OK);
            }
            catch (Exception exception)
            {
                LogError(Request.RequestUri.AbsolutePath, Request.Method.Method, exception.Message);
                return Request.CreateErrorResponse(HttpStatusCode.InternalServerError, "Unable to register customers at this time.");
            }
        }
    }
}