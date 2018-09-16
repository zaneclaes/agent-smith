Agent
----

Based upon the BuildKite Docker image, with Bazel compiled into the new image. The purpose of this container is to provide a static (dockerized) environment in which to coordinate all the standard CLI things that a developer, BuildKite agent, etc. might need to do.

Once up-and-running, it behaves much like a standard BuildKite build (you can just issue commands like you're in your source directory), but has access to Bazel, and can connect to the Smith container.
