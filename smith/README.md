Smith
----

The server builder. Based upon the excellent [Unity3D Docker Image](https://gitlab.com/gableroux/unity3d), Smith makes a couple small tweaks. It keeps itself alive and awaits commands to be issued to it by the Agent. Assuming you have some `$func` to call in Unity CLI, and your Unity project lives at the root of your BuildKite checkout...

`docker exec smith bash /bin/unity_run.sh "${BUILDKITE_BUILD_CHECKOUT_PATH}" $func`
