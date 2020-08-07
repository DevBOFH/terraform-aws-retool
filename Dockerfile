FROM tryretool/backend:latest

USER root
RUN wget -q https://github.com/Droplr/aws-env/raw/b215a696d96a5d651cf21a59c27132282d463473/bin/aws-env-linux-amd64 -O /bin/aws-env && \
chmod +x /bin/aws-env

EXPOSE 3000
ENTRYPOINT ["/bin/bash", "-c", "eval $(/bin/aws-env) && ./docker_scripts/start_api.sh"]
