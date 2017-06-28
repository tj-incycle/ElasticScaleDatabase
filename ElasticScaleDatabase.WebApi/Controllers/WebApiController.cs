using System;
using System.Diagnostics;
using System.Web.Http;
using ElasticScaleDatabase.WebApi.Tenants;

namespace ElasticScaleDatabase.WebApi.Controllers
{
    public abstract class WebApiController : ApiController
    {
        public Guid TenantId => (Guid)Request.Properties[RequireTenantIdAttribute.TenantIdKey];

        protected void LogError(string route, string httpMethod, string message)
        {
            var errorMessage = $"Route: {route}\r\nHTTP Method: {httpMethod}\r\nMessage: {message}";

            Trace.TraceError(errorMessage);
            //TODO: Log to persistant storage
        }
    }
}