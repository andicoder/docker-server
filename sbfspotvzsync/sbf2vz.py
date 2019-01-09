#!/usr/bin/env python3

import mysql.connector 
import datetime
import sys
import requests
import logging
import json
import getopt
import json
import os
from argparse import ArgumentParser

logger = logging.getLogger('sbf2vz')
DEFAULT_LOG_LEVEL = "INFO"
DEFAULT_LIMIT = 100
   
def read_config():

    data = None

    config_file = os.path.splitext(__file__)[0] + '.cfg'

    try:
        with open(config_file) as json_data_file:
            data = json.load(json_data_file)
    except:
        logger.debug("No valid configuration file found") 

    return data

def nearest5minTimestamp(timestamp):
    timestampInt = round(timestamp)
    nearest5min = timestampInt

    if timestampInt % 300 < 150:
        nearest5min = timestampInt - (timestampInt % 300)
    else:
        nearest5min = timestampInt - (timestampInt % 300) + 300

    return nearest5min


def query_result(conn, query):

    logger.debug(query)
    cursor = conn.cursor()
    cursor.execute(query)
    result = cursor.fetchall()
    logger.debug("Result: " + str(result))
    cursor.close()

    return result

def execute_command(conn, query):
    logger.debug(query)
    cursor = conn.cursor()
    cursor.execute(query)
    conn.commit()
    cursor.close()
 

def extract_value_from_result(result, extractionDepth = 1):
    try:
        if extractionDepth == 1:
            if len(result) != 1:
                raise ValueError("Wrong result: " + str(result))

            return result[0];

        else:
            return extract_value_from_result(result[0], extractionDepth - 1)
    except ValueError as err:
        logger.error(err.args)
        raise

def merge_dict(d1, d2, merge_fn=lambda x,y:y):
    """
    Merges two dictionaries, non-destructively, combining 
    values on duplicate keys as defined by the optional merge
    function.  The default behavior replaces the values in d1
    with corresponding values in d2.  (There is no other generally
    applicable merge strategy, but often you'll have homogeneous 
    types in your dicts, so specifying a merge technique can be 
    valuable.)

    Examples:

    >>> d1
    {'a': 1, 'c': 3, 'b': 2}
    >>> merge(d1, d1)
    {'a': 1, 'c': 3, 'b': 2}
    >>> merge(d1, d1, lambda x,y: x+y)
    {'a': 2, 'c': 6, 'b': 4}

    """
    result = dict(d1)
    for k,v in d2.items():
        if k in result:
            result[k] = merge_fn(result[k], v)
        else:
            result[k] = v
    return result

def get_generated_power_for_serial(timestamps, serial):
    query = "SELECT `TimeStamp`, SUM(`Power`) FROM `DayData` WHERE `TimeStamp` IN ("
    for i, timestamp in enumerate(timestamps):
        query += str(timestamp)
        if i < len(timestamps) - 1:
            query += ","
    query += ") AND `Serial` = '" + str(serial) + "' GROUP BY `TimeStamp` ASC"

    result = query_result(cnxSpot, query)

    power_values = dict()
    for value in result:
        try:
            power_values[value[0]] = round(value[1])
        except:
            pass                
 
    return power_values


def get_generated_power(serials, timestamps):
    power_values = dict()
    for serial in serials:
        serial_power = get_generated_power_for_serial(timestamps, serial)
        power_values = merge_dict(power_values, serial_power, merge_fn=lambda x,y:x+y)

    return power_values

def get_last_timestamp_for_energy():
    query = "SELECT `TimeStamp` FROM `DayData` AS `dd`  WHERE NOT ISNULL(`TotalYield`) ORDER BY `dd`.`TimeStamp` DESC LIMIT 1"
    result = query_result(cnxSpot, query)
    if len(result) > 0:
        return extract_value_from_result(result, 2)
    return None

def get_generated_energy_for_serial(timestamp, serial):
    energy = 0
    query = "SELECT `TotalYield` FROM `DayData` AS `dd` WHERE `dd`.`TimeStamp` <= " + str(timestamp) + \
        " AND `dd`.`Serial` = " + str(serial) + " ORDER BY `dd`.`TimeStamp` DESC LIMIT 1"
    result = query_result(cnxSpot, query)
    if len(result) > 0:
        extracted_energy = extract_value_from_result(result, 2)
        if extracted_energy != None:
            energy = extracted_energy
    return energy


def get_generated_energy(serials, timestamps):
    energy_values = {}
    for timestamp in timestamps:
        energy = 0
        for serial in serials:
            energy += get_generated_energy_for_serial(timestamp, serial)
        energy_values[timestamp] = energy
    return energy_values


def get_timestamps_not_added():
    timestamps = []
    query = "SELECT `dd`.`TimeStamp` FROM `DayData` AS `dd` WHERE ISNULL(`dd`.`VZ`) GROUP BY `dd`.`TimeStamp` ORDER BY `dd`.`TimeStamp` ASC " + \
            "LIMIT " + str(config['mysql']['limit'])
    
    try:
        result = query_result(cnxSpot, query)
        #extract timestamps
        for value in result:
            timestamps.append(extract_value_from_result(value))
    except:
        logger.info("There are no entries to add")
    return timestamps


def get_serials():

    serials = []
    query = "SELECT `Serial` FROM `Inverters`"
    result = query_result(cnxSpot, query)

    for value in result:
        serials.append(extract_value_from_result(value))

    return serials

def add_data(uuid, timestamp, value):
    url = config['vz']['vzurl'] + "/data/" + uuid + ".json?ts=" + str(timestamp) + "&value=" + str(value)
    r = requests.post(url)
    
    if r.status_code != 200:
        js = r.json()
        raise RuntimeError(js['exception']['type'] + ": " + js['exception']['message'])

def add_energy_to_vz(energy_values):
    for key, value in sorted(energy_values.items()):
        timestamp = key
        timestampVZ = timestamp * 1000
        energy = value
        try:
            add_data(config['vz']['energy-uuid'], timestampVZ, energy)
        except RuntimeError as err:
            logger.error(err.args[0])
        else:
            logger.info("Added Energy (" + str(datetime.datetime.fromtimestamp(timestamp).strftime("%Y-%m-%d %H:%M")) \
                        + "): " + str(energy / 1000) + " kWh")
        # try:
        #     add_data(config['vz']['total-yield-uuid'], timestampVZ, energy)
        # except RuntimeError as err:
        #     logger.error(err.args[0])
        # else:
        #     logger.info("Added TotalYield (" + str(datetime.datetime.fromtimestamp(timestamp).strftime("%Y-%m-%d %H:%M")) \
        #                 + "): " + str(energy / 1000) + " kWh")


def add_power_to_vz(power_values):
    for key, value in sorted(power_values.items()):
        timestamp = key
        timestampVZ = timestamp * 1000
        power = value
        try:
            add_data(config['vz']['power-uuid'], timestampVZ, power)
        except RuntimeError as err:
            logger.error(err.args[0])
        else:
            logger.info("Added Power (" + str(datetime.datetime.fromtimestamp(timestamp).strftime("%Y-%m-%d %H:%M")) \
                        + "): " + str(power) + " W")

def set_vz_status(timestamps):
    query = "UPDATE `DayData` SET `VZ` = 1 WHERE `TimeStamp` IN ("
    for i, timestamp in enumerate(timestamps):
        query += str(timestamp)
        if i < len(timestamps) - 1:
            query += ","
    query += ")"
    execute_command(cnxSpot, query)


def create_config(argv):

    needed_config = dict()
    needed_config['mysql'] = dict()
    needed_config['mysql']['host'] = 'specify the MySQL host'
    needed_config['mysql']['user'] = 'specify the user name for MySQL'
    needed_config['mysql']['password'] = 'specify the password for MySQL'
    needed_config['mysql']['database'] = 'specify the MySQL database'
    needed_config['vz'] = dict()
    needed_config['vz']['vzurl'] = 'specify the url for volkszahler middleware script'
    needed_config['vz']['energy-uuid'] = 'specify uuid for energy value in volkszahler'
    needed_config['vz']['power-uuid'] = 'specify uuid for power value in volkszahler'
    needed_config['vz']['total-yield-uuid'] = 'specify uuid for total-yield value in volkszahler'

    optional_config = dict()
    optional_config['other'] = dict()
    optional_config['other']['loglevel'] = 'specify the log level'
    optional_config['other']['logfile'] = 'specify the log file'

    config = dict()
    config['mysql'] = dict()
    config['vz'] = dict()
    config['other'] = dict()
    config['mysql']['limit'] = DEFAULT_LIMIT

    config_values = read_config()

    arg_parser = ArgumentParser()

    for cat in needed_config.keys():
        for key, value in needed_config[cat].items():
            arg_parser.add_argument("--" + key, help = value)
            try:
                config[cat][key] = config_values[cat][key]
            except:
                pass

    for cat in optional_config.keys():
        for key, value in optional_config[cat].items():
            arg_parser.add_argument("--" + key, help = value)
            try:
                config[cat][key] = config_values[cat][key]
            except:
                pass

    try:
        arg_parser.parse_args(args=argv)
    except:
        sys.exit(1)

    for cat in needed_config.keys():
        for key, value in needed_config[cat].items():
            try:
                if len(config[cat][key]) == 0:
                    raise RuntimeError()
            except:
                logger.error("Wrong configuration: '" + key + "' must be set under key '"\
                     + cat + "' in config file or with '--" + cat + "' command line param")
                raise

    return config

def init_logger():
    console = logging.StreamHandler()
    formatter = logging.Formatter('[%(asctime)s][%(levelname)s] %(name)s: %(message)s')
    console.setFormatter(formatter)
    logger.addHandler(console)
    logger.setLevel(DEFAULT_LOG_LEVEL)

def config_logger(config):

    level = DEFAULT_LOG_LEVEL
    try:
        level = config['other']['loglevel']
    except:
        pass

    try:
        filename = config['other']['logfile']

        if not os.path.exists(os.path.dirname(filename)): 
            raise RuntimeError()

        filelog = logging.FileHandler(filename, delay=True)
        formatter = logging.Formatter('[%(asctime)s][%(levelname)s] %(name)s: %(message)s')
        filelog.setFormatter(formatter)
        logger.addHandler(filelog)
    except:
        pass

    try:
        logger.setLevel(level)
    except:
        raise


def main(argv):

    global cnxSpot
    global config

    init_logger()

    config = create_config(argv)
    config_logger(config)

    logger.info("sbf2vz - insert values from SBFspot into volkszahler.")
    logger.info("Copyright (C) 2016 Andreas Körner.")

    logger.info("Commandline Args: " + str(argv))

    try:
        cnxSpot = mysql.connector.connect(user=config['mysql']['user'],
                                password=config['mysql']['password'],
                                host=config['mysql']['host'],
                                database = config['mysql']['database'])

        logger.debug("Connected to '" + config['mysql']['host'] + "(" + config['mysql']['database'] + ")'")

        timestamps = get_timestamps_not_added()
        serials = get_serials()

        if len(timestamps) == 0 or len(serials) == 0:
            logger.info("No new data values to add.")
            timestamp = nearest5minTimestamp(datetime.datetime.now().timestamp())

            power_values = dict()
            power_values[timestamp] = 0

            energy_timestamps = []
            last_timestamp = get_last_timestamp_for_energy()
            energy_timestamps.append(last_timestamp)
            tmp_energy_values = get_generated_energy(serials, energy_timestamps)

            energy_values = {}
            energy_values[timestamp] = tmp_energy_values[last_timestamp]

            timestamps.append(timestamp)
            add_energy_to_vz(energy_values)
            add_power_to_vz(power_values)
        else:
            energy_values = get_generated_energy(serials, timestamps)
            power_values = get_generated_power(serials, timestamps)
            add_energy_to_vz(energy_values)
            add_power_to_vz(power_values)

        set_vz_status(timestamps)

    finally:
        cnxSpot.close()
        logger.info("Done.")

if __name__ == "__main__":
   main(sys.argv[1:])
