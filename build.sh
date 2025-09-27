#!/bin/bash

# LaTeX RFP Document Build Script
# Usage: ./build.sh [clean]

set -e

MAIN_FILE="main.tex"
OUTPUT_NAME="main"
BUILD_DIR="build"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if LaTeX is installed
if ! command -v pdflatex &> /dev/null; then
    echo_error "pdflatex not found. Please install LaTeX (e.g., TeX Live or MiKTeX)"
    exit 1
fi

# Clean auxiliary files
clean_aux() {
    echo_info "Cleaning auxiliary files..."
    rm -f "$BUILD_DIR"/*.aux "$BUILD_DIR"/*.log "$BUILD_DIR"/*.out "$BUILD_DIR"/*.toc "$BUILD_DIR"/*.fdb_latexmk "$BUILD_DIR"/*.fls "$BUILD_DIR"/*.synctex.gz "$BUILD_DIR"/*.bbl "$BUILD_DIR"/*.blg "$BUILD_DIR"/*.idx "$BUILD_DIR"/*.ind "$BUILD_DIR"/*.ilg "$BUILD_DIR"/*.lof "$BUILD_DIR"/*.lot 2>/dev/null || true
}

# Clean everything including PDF
clean_all() {
    echo_info "Cleaning all generated files..."
    clean_aux
    rm -f "$BUILD_DIR"/*.pdf 2>/dev/null || true
}

# Build the document
build_document() {
    echo_info "Building LaTeX document..."

    # Create build directory if it doesn't exist
    mkdir -p "$BUILD_DIR"

    # Check if main file exists
    if [ ! -f "$MAIN_FILE" ]; then
        echo_error "Main file $MAIN_FILE not found!"
        exit 1
    fi

    # First pass
    echo_info "Running first pdflatex pass..."
    pdflatex -interaction=nonstopmode -output-directory="$BUILD_DIR" -jobname="$OUTPUT_NAME" "$MAIN_FILE"

    # Second pass for references and TOC
    echo_info "Running second pdflatex pass for references..."
    pdflatex -interaction=nonstopmode -output-directory="$BUILD_DIR" -jobname="$OUTPUT_NAME" "$MAIN_FILE"

    # Third pass to ensure everything is correct
    echo_info "Running final pdflatex pass..."
    pdflatex -interaction=nonstopmode -output-directory="$BUILD_DIR" -jobname="$OUTPUT_NAME" "$MAIN_FILE"

    # Create timestamped version in build directory
    if [ -f "$BUILD_DIR/${OUTPUT_NAME}.pdf" ]; then
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
        TIMESTAMPED_NAME="$BUILD_DIR/main_${TIMESTAMP}.pdf"
        cp "$BUILD_DIR/${OUTPUT_NAME}.pdf" "$TIMESTAMPED_NAME"

        echo_info "Build successful! Output: $BUILD_DIR/${OUTPUT_NAME}.pdf"
        echo_info "Timestamped copy: $TIMESTAMPED_NAME"
        echo_info "File size: $(ls -lh $BUILD_DIR/${OUTPUT_NAME}.pdf | awk '{print $5}')"
    else
        echo_error "Build failed! PDF not generated."
        exit 1
    fi
}

# Main script logic
case "$1" in
    "clean")
        clean_all
        ;;
    "")
        build_document
        ;;
    *)
        echo "Usage: $0 [clean]"
        echo "  clean  - Remove all generated files"
        echo "  (none) - Build the document"
        exit 1
        ;;
esac