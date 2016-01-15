---
layout: post
title: Finding the Git Commit Id of your continuously deployed Azure Web App
---

Azure supports [continuous deployment](https://azure.microsoft.com/en-us/documentation/articles/web-sites-publish-source-control/) of Azure Web Apps from sources like GitHub and BitBucket. Recently, I found the need for the Git commit id of my currently deployed Azure Web Site. I was surprised to find it was not readily available. Here is where you can find it.

Kudu
----

After some research, I learned that Azure uses [Kudu](https://github.com/projectkudu/kudu) as the system for Git deployments of Azure Web Apps. I also discovered this [issue](https://github.com/projectkudu/kudu/issues/1336) where another person was looking for their Git commit id as well. Near the end of the conversation, David Ebbo provides us [two options](https://github.com/projectkudu/kudu/issues/1336#issuecomment-55974966) where we can find our Git commit id. 

1. In the environment variable `SCM_COMMIT_ID` <u>during</u> the deployment process
2. In the file `%home%\site\deployments\active` <u>after</u> the deployment process

Being a developer, I would rather write code than write deployment scripts. So, I picked option two.

Code
----

The only text inside the `%home%\site\deployments\active` file is the Git commit id. So, all we need to do is read the contents of the file.

    using System;
    using System.IO;

    namespace Azure
    {
        public static class Deployment
        {
            private static string _commitId;

            public static string GetGitCommitId()
            {
                if (_commitId != null)
                    return _commitId;

                var path = Environment.ExpandEnvironmentVariables(@"%home%\site\deployments\active");

                _commitId = File.Exists(path)
                          ? File.ReadAllText(path)
                          : string.Empty;

                return _commitId;
            }
        }
    }

Caution
--------
As David Ebbo points out in his [comment](https://github.com/projectkudu/kudu/issues/1336#issuecomment-55974966), using this file does make some assumptions about the Kudu file structure. So, it may change in the future.