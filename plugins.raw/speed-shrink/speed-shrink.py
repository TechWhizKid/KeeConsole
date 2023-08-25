import zlib
import argparse

def compress_file(filename):
    try:
        with open(filename, 'rb') as file:
            data = file.read()
            compressed_data = zlib.compress(data, zlib.Z_BEST_COMPRESSION)
            with open(filename, 'wb') as file:
                file.write(compressed_data)
        print(f"File '{filename}' compressed successfully!")
    except IOError:
        print(f"Error compressing file '{filename}'.")

def decompress_file(filename):
    try:
        with open(filename, 'rb') as file:
            data = file.read()
            decompressed_data = zlib.decompress(data)
            with open(filename, 'wb') as file:
                file.write(decompressed_data)
        print(f"File '{filename}' decompressed successfully!")
    except IOError:
        print(f"Error decompressing file '{filename}'.")

def main():
    parser = argparse.ArgumentParser(description='File Compression/Decompression')
    parser.add_argument('-c', action='store_true', help='Compress the file')
    parser.add_argument('-d', action='store_true', help='Decompress the file')
    parser.add_argument('filename', type=str, help='File to process')
    args = parser.parse_args()

    if args.c:
        compress_file(args.filename)
    elif args.d:
        decompress_file(args.filename)
    else:
        print('Please specify the operation (-c for compress, -d for decompress)')

if __name__ == '__main__':
    main()
