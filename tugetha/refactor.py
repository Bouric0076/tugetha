import os
import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    original = content
    
    # Needs go_router import
    if 'Navigator.' in content and 'package:go_router/go_router.dart' not in content:
        content = "import 'package:go_router/go_router.dart';\n" + content

    # Simple replaces
    content = content.replace('Navigator.pop(context)', 'context.pop()')
    
    # Navigator.push(context, MaterialPageRoute(builder: (_) => const Screen()))
    # Regex for single line basic
    content = re.sub(r'Navigator\.pushReplacement\(\s*context,\s*MaterialPageRoute\(\s*builder:\s*\(_\)\s*=>\s*const\s*(\w+)\(\)\s*,\s*\)\s*,\s*\)', lambda m: f"context.go('/{m.group(1)[:1].lower() + m.group(1)[1:].replace('Screen', '')}')", content)
    
    content = re.sub(r'Navigator\.pushAndRemoveUntil\(\s*context,\s*MaterialPageRoute\(\s*builder:\s*\(_\)\s*=>\s*const\s*(\w+)\(\)\s*\),\s*\(_\)\s*=>\s*false,\s*\)', lambda m: f"context.go('/{m.group(1)[:1].lower() + m.group(1)[1:].replace('Screen', '')}')", content)

    # push
    content = re.sub(r'Navigator\.push\(\s*context,\s*MaterialPageRoute\(\s*builder:\s*\(_\)\s*=>\s*const\s*(\w+)\(\)\s*,\s*\)\s*,\s*\)', lambda m: f"context.push('/{m.group(1)[:1].lower() + m.group(1)[1:].replace('Screen', '')}')", content)

    # single line or multiline without const
    # Splash -> Home etc
    content = content.replace("context.go('/home')", "context.go('/home')") # already correct

    if content != original:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Updated {filepath}")

for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
