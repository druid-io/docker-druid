#!/usr/bin/env python
import time
import argparse
import requests
from requests.exceptions import ConnectionError


def post_file(file, url):
    headers = {'Content-Type': 'application/json'}
    with open(file, 'r') as file_handler:
        json = file_handler.read()
    attempt = 0
    while(attempt < 22):
        try:
            return requests.post(url, data=json, headers=headers)
        except ConnectionError:
            attempt = attempt + 1
            print("Indexing attempt {0}, Druid not up yet..".format(attempt))
            time.sleep(10)


def run(druid_host, index_file):
    """
    Provision the druid database with a new data source
    :param druid_host: The host of the overlord
    :param index_file:
    :return:
    """
    druid_task_id = submit_job(druid_host, index_file)
    print("Job running under task id {0}".format(druid_task_id))
    wait_until_indexed(druid_host, druid_task_id)
    wait_until_available(druid_host)


def submit_job(druid_host, index_file):
    url = "http://{0}:8081/druid/indexer/v1/task".format(druid_host)
    req_index = post_file(
        index_file,
        url
    )
    # Start indexing job
    if req_index.status_code != 200:
        raise ValueError("Did not get HTTP 200 when submitting the job")
    req_json = req_index.json()
    return req_json['task']


def wait_until_indexed(druid_host, druid_task_id):
    url = "http://{0}:8081/druid/indexer/v1/task".format(druid_host)
    # Wait until the job is completed
    running = True
    sec = 0
    while running:
        sec = sec + 1

        req_status = requests.get("{0}/{1}/status".format(url, druid_task_id))

        status = req_status.json()['status']['status']
        if status == 'RUNNING':
            print("Job still running for {0} seconds...".format(sec))
            time.sleep(1)
        elif status == 'SUCCESS':
            running = False  # Great success!
        elif status == 'FAILED':
            raise ValueError('The indexing job failed for an unknown reason!')
        else:
            raise ValueError(
                'We received an unknown status: {0}'.format(status)
            )
    print('Successful index')


def wait_until_available(druid_host):
    url = "http://{0}:8081/druid/coordinator/v1/loadstatus".format(druid_host)
    # Wait until the job is completed
    sec = 0
    while sec < 180:
        sec = sec + 1
        req_status = requests.get(url)
        # Returns an array of all the available indexes
        response = req_status.json()
        datasources = req_status.json().keys()
        # Wait until the data source shows up in the list
        if len(datasources) > 0:
            # Wait until it is loaded 100%
            if response[datasources[0]] == 100.0:
                print("Data source is listed and loaded!")
                return True
        # Wait for a second and check again
        print("Waiting for {0} seconds for the data source to become available...".format(sec))
        time.sleep(1)
    # The data source did not available within a reasonable time span
    raise RuntimeError("Data source did not become available in 180 seconds.")


def main():
    parser = argparse.ArgumentParser(
        description='Start indexing job for Druid'
    )
    parser.add_argument('--file',
                        dest='file',
                        help='The index json file for starting an indexing job')
    parser.add_argument('--druid-host',
                        dest='druid_host',
                        help='The machine where the druid hosts are running',
                        default='localhost')
    args = parser.parse_args()
    run(args.druid_host, args.file)


main()
