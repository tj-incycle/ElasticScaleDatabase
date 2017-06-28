using System;
using System.Diagnostics;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http.Controllers;
using System.Web.Http.Filters;

namespace ElasticScaleDatabase.WebApi.Tenants
{
    public class RequireTenantIdAttribute : ActionFilterAttribute
    {
        public const string IneightTenantHeader = "X-IN8-TenantId";
        public const string TenantIdKey = "TenantId";

        public override void OnActionExecuting(HttpActionContext actionContext)
        {

            try
            {
                if (!actionContext.Request.Headers.Any())
                {
                    actionContext.Response = SetErrorResponse(HttpStatusCode.BadRequest, "Missing headers");
                    return;
                }

                if (!actionContext.Request.Headers.Contains(IneightTenantHeader))
                {
                    actionContext.Response = SetErrorResponse(HttpStatusCode.BadRequest, $"Missing the '{IneightTenantHeader}' header");
                    return;
                }

                var tenantIdheaderValue = actionContext.Request.Headers.GetValues(IneightTenantHeader).First();

                Guid tenantId;

                if (!Guid.TryParse(tenantIdheaderValue, out tenantId))
                {
                    actionContext.Response = SetErrorResponse(HttpStatusCode.BadRequest, $"The value for '{IneightTenantHeader}' header is invalid");
                    return;
                }

                actionContext.Request.Properties.Add(TenantIdKey, tenantId);

            }
            catch (Exception exception)
            {
                Trace.TraceError(exception.Message);
                actionContext.Response = SetErrorResponse(HttpStatusCode.InternalServerError, "Unable to process requests at this time");
                return;
            }


            base.OnActionExecuting(actionContext);
        }

        private HttpResponseMessage SetErrorResponse(HttpStatusCode httpStatusCode, string message)
        {
            return new HttpResponseMessage(httpStatusCode)
            {
                Content = new StringContent(message)
            };
        }

    }
}