import os
import re
import sys
import shutil

def inject_xml(source_path, target_path):
    # If the target file doesn't exist yet (e.g., a brand new quest file),
    # create the necessary folders and copy the master English file over directly.
    if not os.path.exists(target_path):
        print(f"    -> Target {target_path} missing. Copying master English file as base.")
        os.makedirs(os.path.dirname(target_path), exist_ok=True)
        shutil.copy2(source_path, target_path)
        return

    with open(source_path, 'r', encoding='utf-8') as f:
        src_content = f.read()
        
    with open(target_path, 'r', encoding='utf-8') as f:
        tgt_content = f.read()
        
    # 1. Extract target language translations
    tgt_rows = re.findall(r'(<Row>.*?</Row>)', tgt_content, flags=re.DOTALL)
    translations = {}
    
    for r in tgt_rows:
        cells = re.findall(r'(<Cell>.*?</Cell>)', r, flags=re.DOTALL)
        if len(cells) >= 2:
            data1 = re.search(r'<Data[^>]*>(.*?)</Data>', cells[0], flags=re.DOTALL)
            if data1:
                key = data1.group(1)
                translations[key] = cells[1] 
                
    # 2. Build the new content based on the source file's structure
    parts = re.split(r'(<Row>.*?</Row>)', src_content, flags=re.DOTALL)
    
    new_parts =[]
    updated_count = 0
    new_count = 0
    
    for p in parts:
        if p.startswith('<Row>'):
            cells = re.findall(r'(<Cell>.*?</Cell>)', p, flags=re.DOTALL)
            if len(cells) >= 2:
                data1 = re.search(r'<Data[^>]*>(.*?)</Data>', cells[0], flags=re.DOTALL)
                if data1:
                    key = data1.group(1)
                    if key in translations:
                        p = p.replace(cells[1], translations[key])
                        updated_count += 1
                    else:
                        new_count += 1
            new_parts.append(p)
        else:
            new_parts.append(p)
            
    final_content = "".join(new_parts)
    
    # 3. Create a backup
    backup_path = target_path + '.bak'
    shutil.copy2(target_path, backup_path)
    
    # 4. Save the newly injected target file
    with open(target_path, 'w', encoding='utf-8') as f:
        f.write(final_content)
        
    print(f"    -> Updated {os.path.basename(target_path)} (Retained: {updated_count}, New/Untranslated: {new_count})")

if __name__ == '__main__':
    # Define all the specific files you want to track and update
    files_to_process =[
        'strings.xml',
        'dialogue_strings.xml',
        'catalogue_strings.xml',
        'quests/other_strings.xml',
        'quests/rank2_strings.xml',
        'quests/rank3_strings.xml',
        'quests/rank4_strings.xml',
        'quests/tutorial_strings.xml'
    ]

    print("Starting batch string injection process...\n")
    
    # Iterate through all language folders (fr, de, etc.)
    for lang_folder in os.listdir('.'):
        if os.path.isdir(lang_folder):
            print(f"--- Processing Language: {lang_folder.upper()} ---")
            
            for file_rel_path in files_to_process:
                # Normalize paths so it works perfectly on Windows or Linux
                file_rel_path = os.path.normpath(file_rel_path)
                
                # Master is in 'assets/', so we step up one directory ('..')
                source_xml = os.path.join('..', file_rel_path)
                target_xml = os.path.join(lang_folder, file_rel_path)
                
                if not os.path.exists(source_xml):
                    print(f"[!] Error: Master file not found at {source_xml}")
                    continue
                    
                inject_xml(source_xml, target_xml)
            print("")
            
    print("Batch processing complete!")