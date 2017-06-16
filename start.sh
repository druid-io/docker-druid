#!/bin/bash
case "$1" in
	historical)
		echo "STARTING HISTORICAL"
		cat  /etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/historical-supervisord.conf > /etc/supervisor/conf.d/run-supervisord.conf
		;;
	broker)
		echo "STARTING BROKER"
		cat  /etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/broker-supervisord.conf > /etc/supervisor/conf.d/run-supervisord.conf
		;;
	coordinator)
		echo "STARTING CORDINATOR"
		cat  /etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/coordinator-supervisord.conf > /etc/supervisor/conf.d/run-supervisord.conf
		;;
	middleManager)
		echo "STARTING MIDDLEMANAGER"
		cat  /etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/middleManager-supervisord.conf > /etc/supervisor/conf.d/run-supervisord.conf
		;;
	overlord)
		echo "STARTING OVERLORD"
		cat  /etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/overlord-supervisord.conf > /etc/supervisor/conf.d/run-supervisord.conf
		;;
	zookeeper)
	echo "STARTING OVERLORD"
	cat  /etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/zookeeper-supervisord.conf > /etc/supervisor/conf.d/run-supervisord.conf
		;;
	mysql)
	echo "STARTING MYSQL"
	cat  /etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/mysql-supervisord.conf > /etc/supervisor/conf.d/run-supervisord.conf
		;;
	all)
	echo "STARTING DRUID"
	cat /etc/supervisor/conf.d/supervisord.conf  /etc/supervisor/conf.d/zookeeper-supervisord.conf  /etc/supervisor/conf.d/mysql-supervisord.conf  /etc/supervisor/conf.d/historical-supervisord.conf /etc/supervisor/conf.d/broker-supervisord.conf /etc/supervisor/conf.d/coordinator-supervisord.conf  /etc/supervisor/conf.d/middleManager-supervisord.conf > /etc/supervisor/conf.d/run-supervisord.conf
		;;
	*)
	    echo "Usage: $NAME {historical|broker|coordinator|middleManager|overlord}" >&2
	    exit 1
	    ;;
esac

export HOSTIP="$(resolveip -s $HOSTNAME)" && exec /usr/bin/supervisord -c /etc/supervisor/conf.d/run-supervisord.conf