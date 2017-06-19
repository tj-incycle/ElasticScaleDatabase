using System.Diagnostics;
using System.Web.Http;

namespace ElasticScaleDatabase.WebApi.Controllers
{
    public abstract class WebApiController : ApiController
    {
        protected void LogError(string route, string httpMethod, string message)
        {
            var errorMessage = $"Route: {route}\r\nHTTP Method: {httpMethod}\r\nMessage: {message}";

            Trace.TraceError(errorMessage);
            //TODO: Log to persistant storage
        }
    }
}