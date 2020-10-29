package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"time"
)

func indexHandler(w http.ResponseWriter, r *http.Request) {
	var upstreamUri, serviceName string
	var ok bool
	startTime := time.Now()
	hostName, err := os.Hostname()
	if err != nil {
		log.Printf("Error: %s", err)
		return
	}
	upstreamUri, ok = os.LookupEnv("UPSTREAM_URI")
	if !ok {
		upstreamUri = "http://time.jsontest.com"
	}

	serviceName, ok = os.LookupEnv("SERVICE_NAME")
	if !ok {
		serviceName = hostName
	}

	resp, err := http.Get(upstreamUri)
	if err != nil {
		return
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return
	}
	fmt.Fprintf(w, "%s/%s - %fsecs<br/>"+
		"%s -> %s", serviceName, hostName,
		time.Now().Sub(startTime).Seconds(), upstreamUri, body)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("OK"))
}

func main() {
	http.HandleFunc("/healthz", healthHandler)
	http.HandleFunc("/", indexHandler)
	log.Fatal(http.ListenAndServe(":8080", nil))
}
