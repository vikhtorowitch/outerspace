# For more information, please refer to https://aka.ms/vscode-docker-python
FROM python:2.7.9-slim

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

# Install pip requirements
COPY requirements.txt .
RUN python -m pip install -r requirements.txt

WORKDIR /app
COPY . /app

RUN chmod +x turn.sh

#Install Cron
RUN /bin/cp -rf patch/sources.list /etc/apt/sources.list
RUN apt-get update
RUN apt-get -o Dpkg::Options::="--force-overwrite" install -y cron --force-yes

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-python-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

RUN chmod +x turn.sh

# Add the cron job
RUN crontab -l | { cat; echo "@hourly bash /app/turn.sh"; } | crontab -

EXPOSE 9080

# Create a new galaxy and start time
#RUN python2 ./tools/osclient_cli.py --newgalaxy=Alpha Circle3CP admin
#RUN python2 ./tools/osclient_cli.py --starttime admin

CMD cron
CMD ["python2", "./outerspace.py", "server"]
