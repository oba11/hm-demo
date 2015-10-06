FROM alpine

RUN apk add --update python python-dev py-pip && rm -rf /var/cache/apk/*

COPY ./src /src
WORKDIR /src

RUN pip install -r requirements.txt
EXPOSE 8080
CMD ["python", "app.py"]
