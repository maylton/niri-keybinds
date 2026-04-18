import sys
import json
import os
from pathlib import Path
import kdl

NIRI_DIR = Path(os.path.expanduser("~/.config/niri"))
MAIN_CONFIG = NIRI_DIR / "config.kdl"

def get_keybinds_file_path():
    """Encontra o arquivo real que contém o bloco 'binds'."""
    if not MAIN_CONFIG.exists():
        return None

    try:
        with open(MAIN_CONFIG, 'r') as f:
            doc = kdl.parse(f.read())
    except Exception:
        return None

    for node in doc.nodes:
        if node.name == "binds":
            return MAIN_CONFIG

    for node in doc.nodes:
        if node.name == "include" and node.args:
            include_path = str(node.args[0]).strip('"')
            full_path = (NIRI_DIR / include_path).resolve()
            
            if full_path.exists():
                try:
                    with open(full_path, 'r') as inc_f:
                        inc_doc = kdl.parse(inc_f.read())
                        for inc_node in inc_doc.nodes:
                            if inc_node.name == "binds":
                                return full_path
                except Exception:
                    continue 
    return None

def read_keybinds():
    """Lê os atalhos e retorna um JSON."""
    target_file = get_keybinds_file_path()
    
    if not target_file:
        print(json.dumps({"error": "Arquivo de binds não encontrado."}))
        return

    try:
        with open(target_file, 'r') as f:
            doc = kdl.parse(f.read())
    except Exception as e:
        print(json.dumps({"error": f"Falha ao fazer parse do KDL: {e}"}))
        return

    binds_list = []
    binds_node = None
    
    for node in doc.nodes:
        if node.name == "binds":
            binds_node = node
            break
            
    if not binds_node or not binds_node.nodes:
        print(json.dumps([]))
        return

    for bind in binds_node.nodes:
        key_combo = bind.name
        action_str = ""
        
        if bind.nodes:
            action_node = bind.nodes[0]
            action_name = action_node.name
            
            args = [str(arg) for arg in action_node.args]
            if args:
                formatted_args = ' '.join(f'"{arg}"' if ' ' in arg or not arg.isalnum() else arg for arg in args)
                action_str = f"{action_name} {formatted_args}"
            else:
                action_str = action_name
                
        binds_list.append({
            "key": key_combo,
            "action": action_str
        })
        
    print(json.dumps(binds_list, indent=2))

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "read":
        read_keybinds()
    else:
        # Padrão para teste rápido no terminal
        read_keybinds()