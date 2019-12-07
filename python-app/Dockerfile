FROM python:3.8-alpine
MAINTAINER Oluwaseun Obajobi <oba@obajobi.com>

COPY ./src/requirements.txt /src/requirements.txt
WORKDIR /src

RUN pip install -r requirements.txt
COPY ./src /src

EXPOSE 80
CMD ["python", "app.py"]
