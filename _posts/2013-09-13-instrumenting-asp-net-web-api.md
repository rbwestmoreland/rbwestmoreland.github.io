---
layout: post
title: Instrumenting ASP.NET Web API
---

Monitoring our deployed applications is important. It is a proactive approach to finding errors, performance problems, peak usage times, abuse, and much more. When monitoring an API, the following is a good set of starting data-points:

### The Request

* The Url
* The User's Id
* The User's IP Address
* The Timestamp

### The Response

* The Http Status Code
* The Response Time
  
### The Server

* The Machine's Name
* The API Version

#An Example in ASP.NET Web API

The easiest approach to instrumenting in ASP.NET Web API is by using a DelegatingHandler. They sit between the caller and the ApiController in the ASP.NET Web API pipeline.

    using System.Net.Http;
    using System.Threading;
    using System.Threading.Tasks;
    
    namespace System.Net.Http.Instrumentation
    {
        public class TransactionLoggingHandler : DelegatingHandler
        {
            protected async override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request,
                CancellationToken cancellationToken)
            {
                var response = await base.SendAsync(request, cancellationToken);
                return response;
            }
        }
    }

As you can see we have access to both the HttpRequestMessage and the HttpResponseMessage. This is an ideal approach because we can inspect all transactions in the ASP.NET Web API pipeline. Let us continue by expanding on our initial DelegatingHandler and extract our data-points from the request and response.

    using System;
    using System.Diagnostics;
    using System.Net.Http;
    using System.Reflection;
    using System.Threading;
    using System.Threading.Tasks;
    
    namespace System.Net.Http.Instrumentation
    {
        public class TransactionLoggingHandler : DelegatingHandler
        {
            protected async override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request,
                CancellationToken cancellationToken)
            {
                var stopwatch = Stopwatch.Start();
                var response = await base.SendAsync(request, cancellationToken);
                stopwatch.Stop();
                
                Log(request, response, stopwatch);
                
                return response;
            }
            
            private void Log(HttpRequestMessage request, HttpResponseMessage response, Stopwatch stopwatch)
            {
                //request properties
                var requestMethod = request.Method.Method;
                var requestUri = request.RequestUri.ToString();
                var requestTimestamp = DateTime.UtcNow;
                var requestUserId = Thread.CurrentPrincipal.Identity.Name;
                var requestIpAddress = RetrieveClientIPAddress(request);
            
                //response properties
                var responseStatusCode = (int)response.StatusCode;
                var responseTimeInMilliseconds = stopwatch.ElapsedMilliseconds;
            
                //server &, application properties
                var machineName = Environment.MachineName;
                var releaseVersion = Assembly.GetExecutingAssembly().GetName().Version;

                //todo: log to your favorite persistence store
            }
        }
    }

Now, let us make our logging asynchronous. By using `Task.Run(...)`, our response will be returned to the consumer without waiting for our logging task to complete. This allows us to log our transactions without increasing our APIs response times.

    using System;
    using System.Diagnostics;
    using System.Net.Http;
    using System.Reflection;
    using System.Threading;
    using System.Threading.Tasks;
    
    namespace System.Net.Http.Instrumentation
    {
        public class TransactionLoggingHandler : DelegatingHandler
        {
            protected async override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request,
                CancellationToken cancellationToken)
            {
                var stopwatch = Stopwatch.Start();
                var response = await base.SendAsync(request, cancellationToken);
                stopwatch.Stop();
                
                Task.Run(() => Log(request, response, stopwatch), cancellationToken);
                
                return response;
            }
            
            private void Log(HttpRequestMessage request, HttpResponseMessage response, Stopwatch stopwatch)
            {
                //request properties
                var requestMethod = request.Method.Method;
                var requestUri = request.RequestUri.ToString();
                var requestTimestamp = DateTime.UtcNow;
                var requestUserId = Thread.CurrentPrincipal.Identity.Name;
                var requestIpAddress = RetrieveClientIPAddress(request);
            
                //response properties
                var responseStatusCode = (int)response.StatusCode;
                var responseTimeInMilliseconds = stopwatch.ElapsedMilliseconds;
            
                //server &, application properties
                var machineName = Environment.MachineName;
                var releaseVersion = Assembly.GetExecutingAssembly().GetName().Version;

                //todo: log to your favorite persistence store
            }
        }
    }

Finally, we need to add our DelegatingHandler to the ASP.NET Web API pipeline.

    GlobalConfiguration.Configuration.MessageHandlers.Add(new TransactionLoggingHandler());

#Closing Considerations

As you can see, I have left a `todo` for storing your transactions to your favorite persistence store. How you store and later analyze your data-points is up to you. Depending on the type of analysis and the amount of traffic your API receives you may not want to store *every* transaction. Experiment until you find a good sampling of data to retain for your specific needs.