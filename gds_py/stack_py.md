Executing the command: python -c import subprocess, pandas; print(pandas.read_json(subprocess.check_output(['conda', 'list', '--json']))[['name', 'version', 'build_string', 'channel']].to_markdown())
