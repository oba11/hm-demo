FROM python:3.8-alpine
LABEL maintainer="2796222+oba11@users.noreply.github.com"

COPY ./src/requirements.txt /src/requirements.txt
WORKDIR /src

RUN pip install -r requirements.txt
COPY ./src /src

EXPOSE 8080
CMD ["python", "app.py"]
