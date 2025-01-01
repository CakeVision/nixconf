import os
import argparse
from pathlib import Path
import sys

def process_nix_file(file_path, output_file):
    """Process a single .nix file and write its contents to the output file"""
    try:
        # Check if the file is a symlink
        if file_path.is_symlink():
            print(f"Skipping symlink: {file_path}")
            return True
            
        with open(file_path, 'r') as f:
            content = f.read()
            
        # Write separator and content to output file
        separator = f"\n{'='*80}\n"
        file_header = f"FILE: {file_path}\n{'-'*80}\n"
        
        output_file.write(separator)
        output_file.write(file_header)
        output_file.write(content)
        output_file.write("\n")  # Add newline for cleaner separation
        
        print(f"Processed: {file_path}")
        return True
        
    except Exception as e:
        print(f"Error processing {file_path}: {str(e)}", file=sys.stderr)
        return False

def scan_directory(directory, output_path):
    """Recursively scan directory for .nix files, ignoring symlinks"""
    success_count = 0
    error_count = 0
    total_files = 0
    skipped_symlinks = 0
    
    try:
        # Convert to Path object for better path handling
        dir_path = Path(directory)
        if not dir_path.exists():
            raise FileNotFoundError(f"Directory {directory} does not exist")
        if not dir_path.is_dir():
            raise NotADirectoryError(f"{directory} is not a directory")
        
        # Open output file
        with open(output_path, 'w') as output_file:
            # Write header for the combined file
            output_file.write(f"Combined Nix Files from: {directory}\n")
            output_file.write(f"Generated on: {os.path.basename(output_path)}\n")
            
            # Walk through directory recursively
            for root, dirs, files in os.walk(dir_path, followlinks=False):
                # Remove symlinked directories from dirs list to prevent following them
                dirs[:] = [d for d in dirs if not Path(root).joinpath(d).is_symlink()]
                
                # Filter for .nix files
                nix_files = [f for f in files if f.endswith('.nix')]
                
                for nix_file in nix_files:
                    file_path = Path(root) / nix_file
                    
                    # Skip if the file is a symlink
                    if file_path.is_symlink():
                        print(f"Skipping symlink: {file_path}")
                        skipped_symlinks += 1
                        continue
                        
                    total_files += 1
                    if process_nix_file(file_path, output_file):
                        success_count += 1
                    else:
                        error_count += 1
                    
        # Print summary
        print("\nScan Summary:")
        print(f"Total .nix files found: {total_files}")
        print(f"Successfully processed: {success_count}")
        print(f"Errors encountered: {error_count}")
        print(f"Symlinks skipped: {skipped_symlinks}")
        print(f"\nOutput written to: {output_path}")
        
    except Exception as e:
        print(f"Error scanning directory: {str(e)}", file=sys.stderr)
        return False
        
    return True

def main():
    parser = argparse.ArgumentParser(description='Combine .nix files from a directory into a single file, ignoring symlinks')
    parser.add_argument('directory', help='Directory to scan for .nix files')
    parser.add_argument('-o', '--output', default='combined_nix_files.txt',
                      help='Output file path (default: combined_nix_files.txt)')
    parser.add_argument('-v', '--verbose', action='store_true', help='Enable verbose output')
    
    args = parser.parse_args()
    
    if scan_directory(args.directory, args.output):
        print("\nDirectory scan completed successfully")
        return 0
    else:
        print("\nDirectory scan failed", file=sys.stderr)
        return 1

if __name__ == "__main__":
    sys.exit(main())
