# Container name
CONTAINER_NAME = fastapi-app

# Build the Docker image
.PHONY: build
build:
	@echo "Building Docker image..."
	docker build -t $(CONTAINER_NAME) .

# Run container with Memray exposed (Textual Interface)
.PHONY: memory-profile-realtime
memory-profile-realtime:
	@echo "Running with Memray exposed (textual)"
	docker run --rm -p 8000:8000 -p 8001:8001 $(CONTAINER_NAME) memray-expose

# Run container with Memray saving profile to file
.PHONY: memory-profile
memory-profile:
	@echo "Running with Memray saving profile to file"
	docker run -v ./profiles:/profiles -p 8000:8000 --rm $(CONTAINER_NAME) memray-file

# Generate Memray HTML reports
.PHONY: memory-profile-report
memory-profile-report:
	@echo "Generating Memray HTML reports"
	docker run -v ./profiles:/profiles --rm $(CONTAINER_NAME) memray flamegraph /profiles/memray-profile.bin -o /profiles/memray-flamegraph.html
	docker run -v ./profiles:/profiles --rm $(CONTAINER_NAME) memray table /profiles/memray-profile.bin -o /profiles/memray-table.html

# Run container with Py-Spy in real-time mode
.PHONY: cpu-profile-realtime
cpu-profile-realtime:
	@echo "Running with Py-Spy in real-time mode"
	# Docker -it paramter here is super important !IF not it does not work
	docker run -it --rm -p 8000:8000 $(CONTAINER_NAME) pyspy-realtime

# Run container with Py-Spy and save the profile
.PHONY: cpu-profile
cpu-profile:
	@echo "Running with Py-Spy and saving profile"
	docker run -v ./profiles:/profiles -p 8000:8000 --rm $(CONTAINER_NAME) pyspy-record

# Run container with pyinstrument and save the profile
.PHONY: pyinstrument-profile
pyinstrument-profile:
	@echo "Running with pyinstrument and saving profile"
	docker run -v ./profiles:/profiles -p 8000:8000 --rm $(CONTAINER_NAME) pyspy-instrument

# Run container with pyinstrument and save the profile
.PHONY: pyinstrument-profile-timeline
pyinstrument-profile-timeline:
	@echo "Running with pyinstrument and saving profile timeline"
	docker run -v ./profiles:/profiles -p 8000:8000 --rm $(CONTAINER_NAME) pyspy-instrument-timeline
