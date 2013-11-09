---
layout: post
title: Inversion of Control in ASP.NET Web API
---

Adding Inversion of Control to ASP.NET Web API provides tremendous value. Our `ApiController`s become decoupled from the rest of our codebase, no longer have to manage their dependencies, and become easier to test. Adding Inversion of Control is simple and only takes a few lines of code.

##IDependencyResolver
ASP.NET Web API provides an abstraction for dependency injection containers with the `IDependencyResolver` & `IDependencyScope` interfaces.

    using System;
    
    namespace System.Web.Http.Dependencies
    {
        // Summary:
        //     Represents a dependency injection container.
        public interface IDependencyResolver : IDependencyScope, IDisposable
        {
            // Summary:
            //     Starts a resolution scope.
            //
            // Returns:
            //     The dependency scope.
            IDependencyScope BeginScope();
        }
    }

<!--hulk smash!-->

    using System;
    using System.Collections.Generic;
    
    namespace System.Web.Http.Dependencies
    {
        // Summary:
        //     Represents an interface for the range of the dependencies.
        public interface IDependencyScope : IDisposable
        {
            // Summary:
            //     Retrieves a service from the scope.
            //
            // Parameters:
            //   serviceType:
            //     The service to be retrieved.
            //
            // Returns:
            //     The retrieved service.
            object GetService(Type serviceType);
            //
            // Summary:
            //     Retrieves a collection of services from the scope.
            //
            // Parameters:
            //   serviceType:
            //     The collection of services to be retrieved.
            //
            // Returns:
            //     The retrieved collection of services.
            IEnumerable<object> GetServices(Type serviceType);
        }
    }

##Implementing IDependencyResolver
There are many IoC containers out there. Any will do. In this example, we will use my favorite, [TinyIoC](https://github.com/grumpydev/TinyIoC).

    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Web.Http.Dependencies;
    using TinyIoC;
    
    public class TinyIoCDependencyResolver : IDependencyResolver
    {
        private TinyIoCContainer _container;

        public TinyIoCDependencyResolver(TinyIoCContainer container)
        {
            if (container == null)
                throw new ArgumentNullException("container");

            _container = container;
        }

        public IDependencyScope BeginScope()
        {
            if (_disposed)
                throw new ObjectDisposedException("this", "This scope has already been disposed.");

            return new TinyIoCDependencyResolver(_container.GetChildContainer());
        }

        public object GetService(Type serviceType)
        {
            if (_disposed)
                throw new ObjectDisposedException("this", "This scope has already been disposed.");

            try
            {
                return _container.Resolve(serviceType);
            }
            catch (TinyIoCResolutionException)
            {
                return null;
            }
        }

        public IEnumerable<object> GetServices(Type serviceType)
        {
            if (_disposed)
                throw new ObjectDisposedException("this", "This scope has already been disposed.");

            try
            {
                return _container.ResolveAll(serviceType);
            }
            catch (TinyIoCResolutionException)
            {
                return Enumerable.Empty<object>();
            }
        }

        #region IDisposable

        bool _disposed;

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (_disposed)
                return;

            if (disposing)
                _container.Dispose();

            _disposed = true;
        }

        #endregion IDisposable
    }

##Using IDependencyResolver
Using our `IDependencyResolver` is simple, all we have to do is to register it with our ASP.NET Web API configuration.

    var container = new TinyIoCContainer();
    container.Register<IMyDependency>(new MyDependency());
    
    GlobalConfiguration.Configuration.DependencyResolver = new TinyIoCDependencyResolver(container);

Now, the instantiation of our `ApiController`s pass through our IoC container, injecting our dependencies along the way. Here is an example `ApiController` with a dependency:

    using System;
    using System.Net;
    using System.Net.Http;
    using System.Web.Http;
    
    public class ExampleController : ApiController
    {
        private IMyDependency _myDependency;
    
        public ExampleController(IMyDependency myDependency)
        {
            if (myDependency == null)
                throw new ArgumentNullException("myDependency");
    
            _myDependency = myDependency;
        }
    
        [HttpGet]
        [Route("example")]
        public HttpResponseMessage Test()
        {
            var model = new { Message = "dependency injected!" };
            return Request.CreateResponse(HttpStatusCode.OK, model);
        }
    }

##Conclusion
In a few lines of code, we have added tremendous value to our ASP.NET Web API. Our `ApiController`s are decoupled from the rest of our codebase, no longer have to manage their dependencies, and are easier to test!