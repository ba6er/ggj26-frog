#!/bin/bash

# Convert all m4a files to wav recursively
# Usage: bash convert_m4a_to_wav.sh

echo "Starting m4a to wav conversion..."

# Find all m4a files and convert them
find . -name "*.m4a" -type f | while read file; do
    # Get the directory and filename without extension
    dir=$(dirname "$file")
    filename=$(basename "$file" .m4a)
    output="$dir/$filename.wav"
    
    # Skip if wav already exists
    if [ -f "$output" ]; then
        echo "⏭️  Skipping $file (wav already exists)"
        continue
    fi
    
    echo "🔄 Converting: $file → $output"
    ffmpeg -i "$file" -q:a 9 "$output" -y 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "✅ Success: $output"
    else
        echo "❌ Failed: $file"
    fi
done

echo "✨ Conversion complete!"
