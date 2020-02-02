FROM python:3.8-slim
# FROM python:3.8-alpine

RUN adduser -D iotapi

WORKDIR /home/IoTAPI

COPY Pipfile Pipfile
COPY Pipfile.lock Pipfile.lock

RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
    wget build-essential && \
    wget -O re2.tar.gz https://github.com/google/re2/archive/${re2_version}.tar.gz && \
    mkdir re2 && tar --extract --file "re2.tar.gz" --directory "re2" --strip-components 1 && \
    cd re2 && make install && cd .. && rm -rf re2 && rm re2.tar.gz && \
    apt-get clean autoclean && apt-get autoremove --yes  && rm -rf /var/lib/{apt,dpkg,cache,log}/

# RUN pipenv install --deploy --ignore-pipfile

# Making sure we have pipenv
RUN pip install pipenv
# Updating setuptools
RUN pip install --upgrade setuptools
# Installing specified packages from Pipfile.lock
RUN bash -c 'PIPENV_VENV_IN_PROJECT=1 pipenv sync'

# Print to screen the installed packages for easy debugging
RUN pipenv run pip freeze



RUN pipenv install --dev --sequential && \
    pipenv run pylint analyzer && \
    pipenv run flake8 analyzer --exclude "*pb2*.py" && \
	  pipenv run pytest --log-cli-level=0

COPY main.py ./RUN chown -R iotapi:iotapi ./

USER iotapi

CMD uvicorn api:app --host 0.0.0.0 --port 5057
