#!/bin/bash

# Build script for AnythingLLM with clean reset option
# Usage: ./build.sh [--clean|--reset]

set -e

PROJECT_NAME="anythingllm"
COMPOSE_FILE="docker/docker-compose.yml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."

    if ! command_exists docker; then
        print_error "Docker is not installed or not in PATH"
        exit 1
    fi

    if ! command_exists docker-compose; then
        print_error "Docker Compose is not installed or not in PATH"
        exit 1
    fi

    print_success "Prerequisites check passed"
}

# Function to perform clean reset
perform_clean_reset() {
    print_warning "Performing complete clean reset..."

    # Stop and remove containers, networks
    print_status "Stopping and removing containers..."
    docker-compose -f "$COMPOSE_FILE" down --remove-orphans || true

    # Remove volumes
    print_status "Removing Docker volumes..."
    docker-compose -f "$COMPOSE_FILE" down -v --remove-orphans || true

    # Remove any remaining volumes
    print_status "Removing any remaining Docker volumes..."
    docker volume prune -f || true

    # Clean host directories
    print_status "Cleaning host storage directories..."
    rm -rf server/storage/
    rm -rf collector/hotdir/
    rm -rf collector/outputs/
    rm -rf server/prisma/migrations/

    # Reset environment file
    print_status "Resetting environment configuration..."
    if [ -f "docker/.env" ]; then
        cp docker/.env.example docker/.env
    fi

    # Recreate directories
    print_status "Recreating necessary directories..."
    mkdir -p server/storage
    mkdir -p collector/hotdir
    mkdir -p collector/outputs

    print_success "Clean reset completed"
}

# Function to build and start
build_and_start() {
    print_status "Building and starting $PROJECT_NAME..."

    # Build and start containers
    print_status "Building Docker images..."
    docker-compose -f "$COMPOSE_FILE" up --build -d

    # Wait for containers to be healthy
    print_status "Waiting for containers to be ready..."
    sleep 10

    # Check container status
    if docker-compose -f "$COMPOSE_FILE" ps | grep -q "Up"; then
        print_success "$PROJECT_NAME is now running!"

        # Get container IP/port info
        container_info=$(docker-compose -f "$COMPOSE_FILE" ps)
        print_status "Container status:"
        echo "$container_info"

        print_success "Access $PROJECT_NAME at: http://localhost:3001"
    else
        print_error "Failed to start $PROJECT_NAME"
        print_status "Check logs with: docker-compose -f $COMPOSE_FILE logs"
        exit 1
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --clean, --reset    Perform complete clean reset (removes all data)"
    echo "  --help, -h          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                  # Normal build and start"
    echo "  $0 --clean          # Complete reset and rebuild"
    echo "  $0 --reset          # Same as --clean"
}

# Main script logic
main() {
    local clean_reset=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --clean|--reset)
                clean_reset=true
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    print_status "Starting $PROJECT_NAME build script"
    print_status "Clean reset: $clean_reset"

    # Check prerequisites
    check_prerequisites

    # Perform clean reset if requested
    if [ "$clean_reset" = true ]; then
        perform_clean_reset
    fi

    # Build and start
    build_and_start

    print_success "Build script completed successfully!"
}

# Run main function
main "$@"