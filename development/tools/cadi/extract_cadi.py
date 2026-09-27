import os
import re

def extract_cadi(file_path, output_dir):
    print(f"Loading {file_path} into memory...")
    with open(file_path, 'rb') as f:
        data = f.read()

    os.makedirs(output_dir, exist_ok=True)
    
    # -------------------------------------------------------------------------
    # 1. Extract the Original Filenames from the XML header for reference
    # -------------------------------------------------------------------------
    first_ogg = data.find(b'OggS')
    if first_ogg != -1:
        xml_data = data[:first_ogg].decode('utf-8', errors='ignore')
        
        # Hunt for the original filenames embedded in the XML tags
        names = re.findall(r'<(?:ResourceName|SourceUrl|Url)>(.*?)</(?:ResourceName|SourceUrl|Url)>', xml_data)
        
        # Clean up the paths to just get the file names
        clean_names = []
        for name in names:
            clean = name.replace('\\', '/').split('/')[-1]
            if clean.endswith('.ogg') or clean.endswith('.wav'):
                clean_names.append(clean.replace('.wav', '.ogg')) # CADI sometimes labels source as wav but stores as ogg
                
        # Write them to a manifest for easy reference
        with open(os.path.join(output_dir, "_manifest.txt"), "w") as mf:
            mf.write("Original Filenames found in the CAD file (Order may vary slightly from extracted binaries):\n")
            mf.write("-" * 80 + "\n")
            for name in set(clean_names):
                mf.write(name + "\n")
        
        print(f"Dumped {len(set(clean_names))} original filenames to _manifest.txt")

    # -------------------------------------------------------------------------
    # 2. Carve the Binary Ogg Streams
    # -------------------------------------------------------------------------
    print("Scanning for Ogg Vorbis binary streams...")
    offset = first_ogg if first_ogg != -1 else 0
    file_index = 1
    in_ogg = False
    start_offset = 0

    while offset < len(data) - 27:
        # Check for the OggS magic header (0x4F 0x67 0x67 0x53)
        if data[offset:offset+4] == b'OggS':
            
            # The byte at offset 5 contains the flags (0x02 = BOS, 0x04 = EOS)
            header_type = data[offset+5]
            
            # The byte at offset 26 tells us how many segments are in this page
            page_segments = data[offset+26]

            # Ensure we don't read past the end of the file
            if offset + 27 + page_segments > len(data):
                break

            # Calculate the total size of the payload for this page
            payload_size = sum(data[offset + 27 : offset + 27 + page_segments])
            
            # Total size of the OGG page = 27 byte fixed header + segment table + payload
            page_size = 27 + page_segments + payload_size

            is_bos = (header_type & 0x02) != 0 # Beginning of Stream
            is_eos = (header_type & 0x04) != 0 # End of Stream

            # If this is the start of a new audio file, mark our starting point
            if is_bos and not in_ogg:
                start_offset = offset
                in_ogg = True

            # If this is the end of the audio file, slice it out and save it!
            if is_eos and in_ogg:
                end_offset = offset + page_size
                ogg_data = data[start_offset:end_offset]

                out_path = os.path.join(output_dir, f"audio_{file_index:03d}.ogg")
                with open(out_path, 'wb') as out_f:
                    out_f.write(ogg_data)

                print(f"Extracted {out_path} ({len(ogg_data)} bytes)")
                file_index += 1
                in_ogg = False

            # Jump to the start of the next page
            offset += page_size
            
        else:
            # If we lose the framing, scan forward byte-by-byte to find the next OggS header
            next_ogg = data.find(b'OggS', offset + 1)
            if next_ogg == -1:
                break
            offset = next_ogg

    print(f"\nExtraction complete! {file_index - 1} perfectly intact .ogg files carved.")

if __name__ == "__main__":
    extract_cadi("CADI_Choc3_Adam  FINAL.CAD", "extracted_audio")