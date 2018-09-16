Agent Smith
----

Docker-Composed (1) BuildKite agent + Bazel [agent](agent/README.md) (2) a Unity Linux builder [smith](smith/README.md). You'll need the env. vars `MG_SHR` (contains config, and is where builds are sent). Unless specified, `MG_ENV` is assumed to be `DEV`. Then, just do a `sh run.sh` to bring the agent online.

Required Config
----

A `.ss3` directory inside `MG_SHR` with necessary credential files:

* `.ss3/buildkite_agent_token` the BuildKite agent token
* `.ss3/agent_smith` SSH key
* `.ss3/unity.ulf` Unity licence
* `.ss3/unity_pw` Unity username
* `.ss3/unity_un` Unity password


The Source Directory and "exe"
----

The agent passes commands through to build.sh.