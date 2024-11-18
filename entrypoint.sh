#!/bin/bash

APP_MODULE="main:app"
UVICORN_CMD="uvicorn $APP_MODULE --workers 1 --host 0.0.0.0 --port 8000"

case "$1" in
"memray-expose")
	echo "Running FastAPI with Memray (Textual) and uvicorn"
	textual serve -h 0.0.0.0 -p 8001 -c "memray run -m --live $UVICORN_CMD"
	;;

"memray-file")
	echo "Running FastAPI with Memray and saving profile to file"
	memray run -m --output /profiles/memray-profile.bin $UVICORN_CMD
	;;

"pyspy-realtime")
	echo "Running FastAPI with Py-Spy in real-time mode"
	$UVICORN_CMD &
	PID=$!
	sleep 2 # Wait for Uvicorn to start
	exec py-spy top --gil --idle --pid $PID
	;;

"pyspy-record")
	echo "Running FastAPI with Py-Spy and saving profile"
	$UVICORN_CMD &
	PID=$!
	sleep 2 # Wait for Uvicorn to start
	exec py-spy record -o /profiles/pyspy-profile.svg --pid $PID
	;;

"pyspy-instrument")
	echo "Running FastAPI with pyinstrument"
	export PYINSTRUMENT_PROFILING=True
	exec pyinstrument -r html -o /profiles/pyinstrument.html -m $UVICORN_CMD
	;;

"pyspy-instrument-timeline")
	echo "Running FastAPI with pyinstrument timeline"
	export PYINSTRUMENT_PROFILING=True
	exec pyinstrument -t -r html -o /profiles/pyinstrument-timeline.html -m $UVICORN_CMD
	;;

*)
	echo "Executing command: $@"
	exec $@
	;;
esac
