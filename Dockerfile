FROM python:3.6-alpine

RUN adduser -D myproj

WORKDIR /home/myproj

COPY Pipfile Pipfile

RUN pipenv install --deploy --ignore-pipfile

COPY api.py ./RUN chown -R myproj:myproj ./

USER myproj

CMD uvicorn api:app --host 0.0.0.0 --port 5057
