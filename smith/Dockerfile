FROM gableroux/unity3d:2018.2.6f1

COPY ./docker-entrypoint /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint
COPY ./unity_run.sh /bin/unity_run.sh
RUN chmod +x /bin/unity_run.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]