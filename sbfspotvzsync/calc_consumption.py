#!/usr/bin/env python3

import mysql.connector 
import datetime
import sys
import requests
import logging
import getopt
import json
import os
from argparse import ArgumentParser

logger = logging.getLogger(os.path.splitext(os.path.basename(__file__))[0])
DEFAULT_LOG_LEVEL = "INFO"
DEFAULT_LIMIT = 100
DEFAULT_DAYS = 100
TIMESTAMP_FILENAME = os.path.splitext(__file__)[0] + ".timestamp"
SERIAL = "11094"
   
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
    try:
        cursor = conn.cursor()
        cursor.execute(query)
        conn.commit()
        cursor.close()
    except:
        logger.error(query)
        raise
 

def extract_value_from_result(result, extractionDepth = 1):
    try:
        if extractionDepth == 1:
            if len(result) != 1:
                raise ValueError("Wrong result: " + str(result))

            return result[0]

        else:
            return extract_value_from_result(result[0], extractionDepth - 1)
    except ValueError as err:
        logger.error(err.args)
        raise

def get_timestamps_not_calculated():
    start_timestamp = nearest5minTimestamp(
        round((datetime.datetime.now() - datetime.timedelta(days = int(config['other']['daylimit']))).timestamp()))
    try:
        f = open(TIMESTAMP_FILENAME, 'r')
        start_timestamp = max(int(f.readline()), start_timestamp)
    except:
        pass

    end_timestamp = min(nearest5minTimestamp(round(datetime.datetime.now().timestamp())),
        start_timestamp + (int(config['other']['datalimit']) * 300)) 

    start_datetime = datetime.datetime.fromtimestamp(start_timestamp)
    end_datetime = datetime.datetime.fromtimestamp(end_timestamp)

    logger.info("Calculate timestamps from " + str(start_datetime) + " to " + str(end_datetime))
    timestamps = []
    for timestamp in range(start_timestamp, end_timestamp, 300):
        timestamps.append(timestamp)
    return timestamps

def add_data(uuid, timestamp, value):
    url = config['vz']['vzurl'] + "/data/" + uuid + ".json?operation=delete&ts=" + str(timestamp)
    requests.post(url)
    url = config['vz']['vzurl'] + "/data/" + uuid + ".json?ts=" + str(timestamp) + "&value=" + str(value)
    r = requests.post(url)
    
    if r.status_code != 200:
        js = r.json()
        raise RuntimeError(js['exception']['type'] + ": " + js['exception']['message'])

def add_values_to_vz(values):
    for value in values:
        timestamp = value[0]
        timestampVZ = timestamp * 1000
        power = value[1]
        try:
            add_data(config['vz']['consumption-power-uuid'], timestampVZ, power)
        except RuntimeError as err:
            logger.error(err.args[0])
        else:
            logger.info("Added consumption power (" + str(datetime.datetime.fromtimestamp(timestamp).strftime("%Y-%m-%d %H:%M")) \
                        + "): " + str(power) + " W")


def add_values_to_sbfspot(values):
    if len(values) > 0:
        query = "INSERT INTO Consumption (`TimeStamp`, `PowerUsed`) VALUES "
        for i, value in enumerate(values):
            query += "(" + str(value[0]) + "," + str(value[1]) + ")"
            if i < len(values) - 1:
                query += ","
        query += " ON DUPLICATE KEY UPDATE `PowerUsed` = VALUES(`PowerUsed`)"
        execute_command(cnxSpot, query)

        query = "INSERT INTO DayData (`TimeStamp`,`Serial`,`VZ`) VALUES "
        for i, value in enumerate(values):
            query += "(" + str(value[0]) + ",'" + SERIAL + "',1)"
            if i < len(values) - 1:
                query += ","
        query += " ON DUPLICATE KEY UPDATE `PVoutput` = NULL"
        execute_command(cnxSpot, query)
        logger.info("Updated SBFspot.")
    else:
        logger.info("No values to update SBFspot")


def set_timestamp(timestamps):
    l = len(timestamps)
    if l > 0:
        timestamp = timestamps[l - 1]
        try:
            f = open(TIMESTAMP_FILENAME, 'w')
            f.write(str(timestamp))
            logger.info("Wrote timestamp " + str(datetime.datetime.fromtimestamp(timestamp).strftime("%Y-%m-%d %H:%M")))
        except:
            logger.error("Cannot write timestamp to '" + TIMESTAMP_FILENAME + "'")


def get_vz_data_for_timestamp(timestamp):
    timestamp_vz = timestamp * 1000
    timestamp_from = (timestamp - 300) * 1000
    url = config['vz']['vzurl'] + "/data.json" \
        "?uuid[]=" + config['vz']['import-power-uuid'] + \
        "&uuid[]=" + config['vz']['feeded-power-uuid'] + \
        "&uuid[]=" + config['vz']['generated-power-uuid'] + \
        "&uuid[]=" + config['vz']['import-energy-uuid'] + \
        "&uuid[]=" + config['vz']['feeded-energy-uuid'] + \
        "&uuid[]=" + config['vz']['generated-energy-uuid'] + \
        "&from=" + str(timestamp_from) + "&to=" + str(timestamp_vz)
    r = requests.get(url)
    
    if r.status_code != 200:
        js = r.json()
        raise RuntimeError(js['exception']['type'] + ": " + js['exception']['message'])

    response_json = r.json()
    return {'import':round(response_json['data'][0]['average']),
            'feedin':round(response_json['data'][1]['average']),
            'gen':round(response_json['data'][2]['average']),
            'import-energy':round(response_json['data'][3]['average']),
            'feedin-energy':round(response_json['data'][4]['average']),
            'gen-energy':round(response_json['data'][5]['average']),
          }

def get_ref_data(ref_timestamp):
    timestamp_vz = ref_timestamp * 1000
    timestamp_from = (ref_timestamp - 600) * 1000
    url = config['vz']['vzurl'] + "/data.json" \
        "?uuid[]=" + config['vz']['import-energy-uuid'] + \
        "&uuid[]=" + config['vz']['feeded-energy-uuid'] + \
        "&uuid[]=" + config['vz']['generated-energy-uuid'] + \
        "&from=" + str(timestamp_from) + "&to=" + str(timestamp_vz)
    r = requests.get(url)
    
    if r.status_code != 200:
        js = r.json()
        raise RuntimeError(js['exception']['type'] + ": " + js['exception']['message'])

    response_json = r.json()
    return {'import-energy':round(response_json['data'][0]['average']),
            'feedin-energy':round(response_json['data'][1]['average']),
            'gen-energy':round(response_json['data'][2]['average']),
          }

def get_value(power, energy):
    if energy >= 0:
        return energy
    else:
        return power


def calc_values(ref_timestamp, timestamps):
    values = []
    for timestamp in timestamps:
        try:
            data = get_vz_data_for_timestamp(timestamp)
#            ref_data = get_ref_data(ref_timestamp)
            
            import_power = data['import']
            feed_in_power = data['feedin']
            generated_power = data['gen']
            
            import_energy = data['import-energy']
            feed_in_energy = data['feedin-energy']
            generated_energy = data['gen-energy']

 #          ref_import_energy = ref_data['import-energy']
 #          ref_feed_in_energy = ref_data['feedin-energy']
 #          ref_generated_energy = ref_data['gen-energy']

        except:
            logger.warning("No data values for " + str(datetime.datetime.fromtimestamp(timestamp)))
        else:
            power = generated_power - feed_in_power + import_power
            energy = (generated_energy) - (feed_in_energy) + (import_energy)
            
            value = get_value(power, energy)
            if value >= 0:
                values.append((timestamp, value))
                logger.info("Calculated consumption (" + str(datetime.datetime.fromtimestamp(timestamp).strftime("%Y-%m-%d %H:%M")) \
                        + "): Power: " + str(value) + " W (" + str(generated_power) + "-" + str(feed_in_power) + "+" + str(import_power) + ")"
                        + " Energy: " + str(energy) + " W (" + str(generated_energy) + "-" + str(feed_in_energy) + "+" + str(import_energy) + ")")
            else:
                logger.warning("Skipped consumption (" + str(datetime.datetime.fromtimestamp(timestamp).strftime("%Y-%m-%d %H:%M")) \
                        + "): Power: " + str(value) + " W (" + str(generated_power) + "-" + str(feed_in_power) + "+" + str(import_power) + ")" \
                        + " Energy: " + str(energy) + " W (" + str(generated_energy) + "-" + str(feed_in_energy) + "+" + str(import_energy) + ")")
 
    return values

def create_config(argv):

    needed_config = dict()
    needed_config['mysql'] = dict()
    needed_config['mysql']['host'] = 'specify the MySQL host'
    needed_config['mysql']['user'] = 'specify the user name for MySQL'
    needed_config['mysql']['password'] = 'specify the password for MySQL'
    needed_config['mysql']['database'] = 'specify the MySQL database'
    needed_config['vz'] = dict()
    needed_config['vz']['vzurl'] = 'specify the url for volkszahler middleware script'
    needed_config['vz']['import-power-uuid'] = 'specify uuid for imported power value in volkszahler'
    needed_config['vz']['feeded-power-uuid'] = 'specify uuid for feeded power value in volkszahler'
    needed_config['vz']['consumption-power-uuid'] = 'specify uuid for feeded power value in volkszahler'
    needed_config['vz']['generated-power-uuid'] = 'specify uuid for genrated power value in volkszahler'
    needed_config['vz']['import-energy-uuid'] = 'specify uuid for imported energy value in volkszahler'
    needed_config['vz']['feeded-energy-uuid'] = 'specify uuid for feeded energy value in volkszahler'
    needed_config['vz']['consumption-energy-uuid'] = 'specify uuid for feeded energy value in volkszahler'
    needed_config['vz']['generated-energy-uuid'] = 'specify uuid for genrated energy value in volkszahler'

    optional_config = dict()
    optional_config['other'] = dict()
    optional_config['other']['loglevel'] = 'specify the log level'
    optional_config['other']['logfile'] = 'specify the log file'
    optional_config['other']['daylimit'] = 'specify the limit for days calculated in the past'
    optional_config['other']['datalimit'] = 'specify the limit for data calculated per script call'

    config = dict()
    config['mysql'] = dict()
    config['vz'] = dict()
    config['other'] = dict()
    config['other']['daylimit'] = DEFAULT_DAYS
    config['other']['datalimit'] = DEFAULT_LIMIT

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

def init_db():
    ts = round(datetime.datetime.now().timestamp())
    command = "INSERT INTO Inverters (`Serial`, `Name`, `Type`, `TimeStamp`) " \
       " VALUES('" + SERIAL + "', 'Consumption', 'Consumption Device', " + str(ts) + ") "\
       " ON DUPLICATE KEY UPDATE `TimeStamp`= " + str(ts)
    execute_command(cnxSpot, command)

    query = "SELECT `Key`, `Value` FROM `SBFspot`.`Config` WHERE  `Key`='RefTimeStamp'"
    result = query_result(cnxSpot, query)
    start_timestamp = nearest5minTimestamp(
        round((datetime.datetime.now() - datetime.timedelta(days = int(config['other']['daylimit']))).timestamp()))        
    for value in result:
        try:
            start_timestamp = int(value[1])
        except:
            pass    
    command = "INSERT IGNORE INTO Config (`Key`, `Value`) VALUES ('RefTimeStamp', '" + str(start_timestamp) + "')"
    execute_command(cnxSpot, command)
    return start_timestamp


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

    logger.info("calc_consumption - calculate consumption data from SBFspot and volkszahler.")
    logger.info("Copyright (C) 2016 Andreas Körner.")

    logger.info("Commandline Args: " + str(argv))

    try:
        cnxSpot = mysql.connector.connect(user=config['mysql']['user'],
                                password=config['mysql']['password'],
                                host=config['mysql']['host'],
                                database = config['mysql']['database'])

        logger.debug("Connected to '" + config['mysql']['host'] + "(" + config['mysql']['database'] + ")'")

        ref_timestamp = init_db()

        timestamps = get_timestamps_not_calculated()
        values = calc_values(ref_timestamp, timestamps)
        add_values_to_vz(values)
        add_values_to_sbfspot(values)
        set_timestamp(timestamps)

    finally:
        cnxSpot.close()
        logger.info("Done.")

if __name__ == "__main__":
    main(sys.argv[1:])
